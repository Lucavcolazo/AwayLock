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
    private let prefs = Preferences()
    private let engine = PresenceEngine()
    private let scanner = ProximityScanner()

    /// Avanza una vez por segundo; publicarlo hace que la interfaz se redibuje.
    @Published private(set) var now = Date()
    @Published var hint: String?
    @Published var showAllDevices = false
    /// La lista de dispositivos solo escanea mientras está abierta.
    @Published var deviceListOpen = false {
        didSet { scanner.discovering = deviceListOpen }
    }

    private var lastAutoLock: Date?
    private var pendingUnlockCheck: (lockedAt: Date, unlockedAt: Date)?
    private var observers: [NSObjectProtocol] = []

    init() {
        engine.config = prefs.config
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

    var rssi: Int? { engine.isLost(at: now) ? nil : engine.smoothedRSSI }

    var menuBarSymbol: String {
        guard prefs.enabled else { return "pause.circle" }
        guard prefs.deviceID != nil, scanner.bluetoothOn else { return "iphone.slash" }
        switch engine.state {
        case .present: return "iphone"
        case .leaving: return "figure.walk"
        case .away: return "lock.fill"
        }
    }

    var status: StatusInfo {
        let signal = rssi.map { "\($0) dBm" } ?? "sin lectura"
        let device = prefs.deviceName ?? "Tu iPhone"
        guard prefs.deviceID != nil else {
            return StatusInfo(title: "Elegí tu iPhone", detail: "Abrí «Dispositivo» y acercalo a la Mac",
                              symbol: "iphone.slash", tint: .gray)
        }
        guard scanner.bluetoothOn else {
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
        scanner.nearbyDevices().filter {
            showAllDevices || $0.name?.localizedCaseInsensitiveContains("iPhone") == true
        }
    }

    func select(_ id: UUID?) {
        guard id != prefs.deviceID else { return }
        objectWillChange.send()
        prefs.deviceID = id
        prefs.deviceName = id.flatMap { id in scanner.nearbyDevices().first { $0.id == id }?.name }
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

    func lockNow() {
        ScreenControl.lock()
    }
}
