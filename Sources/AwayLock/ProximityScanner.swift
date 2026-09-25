import CoreBluetooth
import Foundation

struct NearbyDevice {
    let id: UUID
    var name: String?
    var isApple: Bool
    var rssi: Int
    var lastSeen: Date
}

@MainActor
protocol ProximityScannerDelegate: AnyObject {
    func scanner(_ scanner: ProximityScanner, didMeasure rssi: Int)
}

/// Mide la señal de un único dispositivo.
///
/// Si puede, se conecta y le pide la señal cada segundo (lecturas regulares).
/// Mientras no hay conexión, usa los anuncios que el dispositivo emite solo.
/// Tu iPhone y tu Apple Watch mantienen el mismo `identifier` aunque roten su
/// dirección Bluetooth, porque la Mac conoce sus claves por la cuenta de Apple.
@MainActor
final class ProximityScanner: NSObject {
    weak var delegate: ProximityScannerDelegate?

    /// Mientras es true se listan los dispositivos cercanos (menú de dispositivos abierto).
    var discovering = false {
        didSet {
            if discovering { nearby.removeAll() }
            updateScanning()
        }
    }

    /// Solo escuchar anuncios, sin conectarse. Útil si interfiere con otros accesorios Bluetooth.
    var passive = false {
        didSet { if passive != oldValue { restart() } }
    }

    private(set) var targetID: UUID?
    private(set) var connectedName: String?
    var bluetoothOn: Bool { central?.state == .poweredOn }

    /// Queda en nil si se crea sin Bluetooth; todo lo que lo usa pasa antes por `bluetoothOn`.
    private var central: CBCentralManager!
    private var target: CBPeripheral?
    private var nearby: [UUID: NearbyDevice] = [:]
    private var pollTimer: Timer?
    private var lastRead = Date.distantPast

    /// `bluetooth: false` sirve para dibujar la interfaz sin tocar el Bluetooth (capturas).
    init(bluetooth: Bool = true) {
        super.init()
        if bluetooth {
            central = CBCentralManager(delegate: self, queue: .main)
        }
    }

    func monitor(_ id: UUID?) {
        stopPolling()
        if let target, target.state != .disconnected {
            central.cancelPeripheralConnection(target)
        }
        targetID = id
        target = nil
        connectedName = nil
        attach()
    }

    func restart() {
        monitor(targetID)
    }

    func nearbyDevices(now: Date = Date()) -> [NearbyDevice] {
        nearby.values
            .filter { now.timeIntervalSince($0.lastSeen) < 10 }
            .sorted { $0.rssi > $1.rssi }
    }

    private func attach() {
        if bluetoothOn, let targetID, target == nil {
            target = central.retrievePeripherals(withIdentifiers: [targetID]).first
        }
        connect()
        updateScanning()
    }

    private func connect() {
        guard bluetoothOn, !passive, let target, target.state == .disconnected else { return }
        central.connect(target)
    }

    private var isPolling: Bool { pollTimer != nil }

    /// Escaneamos solo cuando hace falta: para listar dispositivos, o cuando
    /// no estamos conectados y dependemos de los anuncios.
    private func updateScanning() {
        guard bluetoothOn else { return }
        let needed = discovering || (targetID != nil && !isPolling)
        if needed && !central.isScanning {
            central.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        } else if !needed && central.isScanning {
            central.stopScan()
        }
    }

    private func startPolling() {
        stopPolling()
        lastRead = Date()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
        updateScanning()
    }

    private func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func poll() {
        guard let target else { return }
        if Date().timeIntervalSince(lastRead) > 5 {
            // La conexión quedó colgada: cortamos y seguimos con los anuncios.
            // Al desconectarse, `connectionDropped` reintenta.
            stopPolling()
            updateScanning()
            central.cancelPeripheralConnection(target)
        } else {
            target.readRSSI()
        }
    }

    private func connectionDropped(_ peripheral: CBPeripheral) {
        guard peripheral == target else { return }
        stopPolling()
        updateScanning()
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            self?.connect()
        }
    }

    private func discovered(_ peripheral: CBPeripheral, advertisement: [String: Any], rssi: Int) {
        guard rssi < 0 else { return }  // 127 = no disponible

        if peripheral.identifier == targetID {
            if target == nil {
                target = peripheral
                connect()
            }
            if !isPolling { delegate?.scanner(self, didMeasure: rssi) }
        }

        guard discovering else { return }
        let maker = advertisement[CBAdvertisementDataManufacturerDataKey] as? Data
        let isApple = maker.map { $0.prefix(2) == Data([0x4C, 0x00]) } ?? false  // ID de Apple: 0x004C
        let name = peripheral.name ?? advertisement[CBAdvertisementDataLocalNameKey] as? String
        let previous = nearby[peripheral.identifier]
        nearby[peripheral.identifier] = NearbyDevice(
            id: peripheral.identifier,
            name: name ?? previous?.name,
            isApple: isApple || previous?.isApple == true,
            // Suavizado simple para que la lista no salte tanto.
            rssi: previous.map { ($0.rssi + rssi) / 2 } ?? rssi,
            lastSeen: Date()
        )
    }
}

extension ProximityScanner: CBCentralManagerDelegate, CBPeripheralDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MainActor.assumeIsolated {
            if central.state == .poweredOn {
                attach()
            } else {
                // Con el Bluetooth apagado los periféricos quedan inválidos.
                stopPolling()
                target = nil
            }
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        MainActor.assumeIsolated {
            discovered(peripheral, advertisement: advertisementData, rssi: RSSI.intValue)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        MainActor.assumeIsolated {
            guard peripheral == target else { return }
            peripheral.delegate = self
            if let name = peripheral.name { connectedName = name }
            startPolling()
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        MainActor.assumeIsolated { connectionDropped(peripheral) }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        MainActor.assumeIsolated { connectionDropped(peripheral) }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        MainActor.assumeIsolated {
            guard peripheral == target, error == nil, RSSI.intValue < 0 else { return }
            lastRead = Date()
            delegate?.scanner(self, didMeasure: RSSI.intValue)
        }
    }

    nonisolated func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        MainActor.assumeIsolated {
            if peripheral == target, let name = peripheral.name { connectedName = name }
        }
    }
}
