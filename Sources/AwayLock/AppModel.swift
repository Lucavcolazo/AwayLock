import AppKit
import AwayLockCore
import ServiceManagement
import SwiftUI

struct StatusInfo {
    let title: String
    let detail: String
    let symbol: String
    let tint: Color
}

/// Une el motor de presencia, el Bluetooth y la pantalla, y expone el estado a la interfaz.
@MainActor
final class AppModel: ObservableObject, ProximityScannerDelegate {
    static let shared = AppModel()
    /// Sale del Info.plist, así la versión se cambia en un solo lugar.
    static var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"

    private let prefs: Preferences
    private let engine = PresenceEngine()
    private let scanner: ProximityScanner
    /// Modo capturas: sin Bluetooth, sin bloquear nada y sin tocar tus ajustes.
    private let isPreview: Bool
    /// Lista de dispositivos de ejemplo para las capturas.
    private var previewDevices: [NearbyDevice]?
    private var previewPermissionDenied = false

    /// Avanza una vez por segundo. No es @Published: redibujar cada segundo con todo
    /// cerrado gastaba CPU de más. `tick()` avisa a la interfaz solo cuando hace falta.
    private(set) var now = Date()
    /// Cuántas vistas (panel, ventana) se están mostrando ahora.
    private var visibleViews = 0
    private var lastMenuBarSymbol = ""
    @Published var hint: String?
    @Published var showAllDevices = false
    /// La lista de dispositivos solo escanea mientras se está mostrando.
    var isListingDevices = false {
        didSet { scanner.discovering = isListingDevices }
    }

    private var lastAutoLock: Date?
    private var pendingUnlockCheck: (lockedAt: Date, unlockedAt: Date)?
    private var observers: [NSObjectProtocol] = []

    init(preview: Bool = false) {
        isPreview = preview
        prefs = Preferences(inMemory: preview)
        scanner = ProximityScanner(bluetooth: !preview)
        engine.config = prefs.config
        // En modo capturas no escuchamos eventos ni corremos el reloj: nada puede bloquear.
        guard !preview else { return }

        scanner.delegate = self
        scanner.passive = prefs.passive
        scanner.monitor(prefs.deviceID)

        observers.append(DistributedNotificationCenter.default().addObserver(
            forName: .init("com.apple.screenIsUnlocked"), object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.screenDidUnlock() }
        })
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.systemDidWake() }
        })

        // En modo .common para que siga corriendo con el panel abierto.
        let ticker = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(ticker, forMode: .common)
    }

    // MARK: - Lógica

    func scanner(_ scanner: ProximityScanner, didMeasure rssi: Int) {
        handle(engine.add(rssi: rssi, at: Date()))
    }

    private func tick() {
        let now = Date()
        handle(engine.evaluate(at: now))
        checkForFalseLock(now: now)
        if let name = scanner.connectedName, name != prefs.deviceName {
            prefs.deviceName = name
        }
        self.now = now

        // Con el panel o la ventana a la vista, refrescamos cada segundo (medidor, cuenta
        // regresiva). Con todo cerrado, solo cuando cambia el ícono de la barra de menú.
        let symbol = menuBarSymbol
        if visibleViews > 0 || symbol != lastMenuBarSymbol {
            lastMenuBarSymbol = symbol
            objectWillChange.send()
        }
    }

    func viewAppeared() {
        visibleViews += 1
        objectWillChange.send()
    }

    func viewDisappeared() {
        visibleViews = max(0, visibleViews - 1)
    }

    private func handle(_ events: [PresenceEvent]) {
        guard prefs.enabled, prefs.deviceID != nil else { return }
        for event in events {
            switch event {
            case .lock:
                guard !ScreenControl.isLocked else { continue }
                lastAutoLock = Date()
                ScreenControl.lock()
            case .returned:
                // Prender la pantalla hace que el Apple Watch te desbloquee solo.
                if prefs.wakeOnReturn && ScreenControl.isLocked { ScreenControl.wakeDisplay() }
            }
        }
    }

    private func screenDidUnlock() {
        let now = Date()
        engine.userUnlocked(at: now)
        if let locked = lastAutoLock, now.timeIntervalSince(locked) < 60 {
            pendingUnlockCheck = (locked, now)
        }
        lastAutoLock = nil
    }

    /// Si desbloqueaste al ratito de un bloqueo automático y unos segundos después
    /// seguimos sin detectarte cerca, lo más probable es que el bloqueo haya sido
    /// falso (estabas sentado con la señal floja). Esperamos antes de decidir porque
    /// confirmar que volviste tarda unos segundos (mediana + tiempo sostenido cerca).
    private func checkForFalseLock(now: Date) {
        guard let check = pendingUnlockCheck, now.timeIntervalSince(check.unlockedAt) >= 8 else { return }
        pendingUnlockCheck = nil
        guard engine.state == .away else { return }
        let seconds = Int(check.unlockedAt.timeIntervalSince(check.lockedAt))
        hint = "Desbloqueaste a los \(seconds) s sin que te detecte. Si estabas en la compu, bajá «Bloquear con señal menor a»."
    }

    private func systemDidWake() {
        // Las lecturas de antes del reposo no sirven. Arrancamos "desarmados" para
        // no bloquearte apenas abrís la tapa.
        engine.reset()
        scanner.restart()
    }

    // MARK: - Estado visible

    private var bluetoothOn: Bool { isPreview || scanner.bluetoothOn }

    var needsBluetoothPermission: Bool {
        isPreview ? previewPermissionDenied : scanner.permissionDenied
    }

    func openBluetoothSettings() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth"
        if let url = URL(string: url) { NSWorkspace.shared.open(url) }
    }
    private var nearbyDevices: [NearbyDevice] { previewDevices ?? scanner.nearbyDevices() }

    var rssi: Int? {
        guard !needsBluetoothPermission, !engine.isLost(at: now) else { return nil }
        return engine.smoothedRSSI
    }

    var menuBarSymbol: String {
        guard !needsBluetoothPermission else { return "exclamationmark.triangle" }
        guard prefs.enabled else { return "pause.circle" }
        guard prefs.deviceID != nil, bluetoothOn else { return "iphone.slash" }
        switch engine.state {
        case .present: return "iphone"
        case .leaving: return "figure.walk"
        case .away: return "lock.fill"
        }
    }

    var status: StatusInfo {
        let signal = rssi.map { "\($0) dBm" } ?? "sin lectura"
        let device = prefs.deviceName ?? "Tu iPhone"
        guard !needsBluetoothPermission else {
            return StatusInfo(title: "Sin permiso de Bluetooth", detail: "Activalo en Ajustes",
                              symbol: "hand.raised.fill", tint: .orange)
        }
        guard prefs.deviceID != nil else {
            return StatusInfo(title: "Elegí tu iPhone", detail: "Abrí «Dispositivo» y acercalo a la Mac",
                              symbol: "iphone.slash", tint: .gray)
        }
        guard bluetoothOn else {
            return StatusInfo(title: "Bluetooth apagado", detail: "Prendelo para medir la señal",
                              symbol: "antenna.radiowaves.left.and.right.slash", tint: .gray)
        }
        guard prefs.enabled else {
            return StatusInfo(title: "En pausa", detail: "\(device) · \(signal)", symbol: "pause.fill", tint: .gray)
        }
        switch engine.state {
        case .present:
            return StatusInfo(title: "Cerca", detail: "\(device) · \(signal)", symbol: "person.fill.checkmark", tint: .green)
        case .leaving(let since):
            let left = max(0, Int((prefs.lockDelay - now.timeIntervalSince(since)).rounded(.up)))
            return StatusInfo(title: "Te estás alejando", detail: "Bloqueo en \(left) s · \(signal)",
                              symbol: "figure.walk", tint: .orange)
        case .away:
            if engine.isLost(at: now) {
                return StatusInfo(title: "Sin señal", detail: "No se escucha a \(device)",
                                  symbol: "antenna.radiowaves.left.and.right.slash", tint: .red)
            }
            return StatusInfo(title: "Lejos", detail: "\(signal) · para volver: \(prefs.nearRSSI) dBm o más",
                              symbol: "lock.fill", tint: .indigo)
        }
    }

    // MARK: - Dispositivo

    var selectedID: UUID? { prefs.deviceID }

    var deviceName: String {
        prefs.deviceName ?? (prefs.deviceID == nil ? "Ninguno" : "Dispositivo elegido")
    }

    /// Por defecto solo iPhones, para no mezclar con el reloj, los AirPods, etc.
    var visibleDevices: [NearbyDevice] {
        nearbyDevices.filter {
            showAllDevices || $0.name?.localizedCaseInsensitiveContains("iPhone") == true
        }
    }

    func select(_ id: UUID?) {
        guard id != prefs.deviceID else { return }
        objectWillChange.send()
        prefs.deviceID = id
        prefs.deviceName = id.flatMap { id in nearbyDevices.first { $0.id == id }?.name }
        hint = nil
        engine.reset()
        scanner.monitor(id)
    }

    // MARK: - Ajustes

    var enabled: Bool {
        get { prefs.enabled }
        set { objectWillChange.send(); prefs.enabled = newValue }
    }

    /// Siempre al menos 5 dBm por debajo de `nearRSSI`.
    var lockRSSI: Int {
        get { prefs.lockRSSI }
        set { objectWillChange.send(); prefs.lockRSSI = min(newValue, prefs.nearRSSI - 5); applyConfig() }
    }

    /// Siempre al menos 5 dBm por encima de `lockRSSI`.
    var nearRSSI: Int {
        get { prefs.nearRSSI }
        set { objectWillChange.send(); prefs.nearRSSI = max(newValue, prefs.lockRSSI + 5); applyConfig() }
    }

    var lockDelay: Int {
        get { Int(prefs.lockDelay) }
        set { objectWillChange.send(); prefs.lockDelay = TimeInterval(newValue); applyConfig() }
    }

    var lostTimeout: Int {
        get { Int(prefs.lostTimeout) }
        set { objectWillChange.send(); prefs.lostTimeout = TimeInterval(newValue); applyConfig() }
    }

    var wakeOnReturn: Bool {
        get { prefs.wakeOnReturn }
        set { objectWillChange.send(); prefs.wakeOnReturn = newValue }
    }

    var passive: Bool {
        get { prefs.passive }
        set { objectWillChange.send(); prefs.passive = newValue; scanner.passive = newValue }
    }

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            objectWillChange.send()
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                hint = "No se pudo cambiar el inicio automático: \(error.localizedDescription)"
            }
        }
    }

    private func applyConfig() {
        engine.config = prefs.config
        hint = nil
    }

    private lazy var mainWindow = MainWindowController(model: self)

    func openMainWindow() {
        mainWindow.show()
    }

    func lockNow() {
        ScreenControl.lock()
    }
}

#if DEBUG
// MARK: - Capturas

enum PreviewScene {
    case near, leaving, away
}

extension AppModel {
    /// Modelo con datos de ejemplo para dibujar el panel en las capturas del README.
    /// Alimenta el motor real con lecturas inventadas, así el estado sale igual que en la app.
    static func preview(_ scene: PreviewScene, devices: Bool = false, permissionDenied: Bool = false) -> AppModel {
        let model = AppModel(preview: true)
        model.previewPermissionDenied = permissionDenied
        let deviceID = UUID()
        model.prefs.deviceID = deviceID
        model.prefs.deviceName = "iPhone de Luca"
        model.prefs.lockRSSI = -75
        model.engine.config = model.prefs.config

        let now = Date()
        func feed(_ rssi: Int, _ seconds: ClosedRange<Int>) {
            for second in seconds {
                _ = model.engine.add(rssi: rssi, at: now.addingTimeInterval(TimeInterval(second)))
            }
        }
        switch scene {
        case .near:
            feed(-48, -8 ... 0)
        case .leaving:
            feed(-48, -12 ... -5)
            feed(-84, -4 ... 0)
        case .away:
            feed(-48, -30 ... -20)
            feed(-86, -19 ... 0)
        }
        model.now = now

        if devices {
            model.previewDevices = [
                NearbyDevice(id: deviceID, name: "iPhone de Luca", isApple: true, rssi: -46, lastSeen: now),
                NearbyDevice(id: UUID(), name: "iPhone del trabajo", isApple: true, rssi: -71, lastSeen: now),
            ]
        }
        return model
    }
}
#endif
