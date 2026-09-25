import Foundation

public struct PresenceConfig: Equatable {
    /// Si la señal (mediana) cae por debajo de esto, empezás a "irte".
    public var lockRSSI: Int
    /// Por encima de esto se considera que volviste. Tiene que ser mayor que `lockRSSI`:
    /// el hueco entre los dos es lo que evita el ida y vuelta.
    public var nearRSSI: Int
    /// Segundos seguidos lejos antes de bloquear.
    public var lockDelay: TimeInterval
    /// Segundos sin ninguna lectura para dar el dispositivo por perdido.
    public var lostTimeout: TimeInterval
    /// Segundos seguidos cerca para considerar que volviste.
    public var nearHold: TimeInterval
    /// Ventana de lecturas sobre la que se calcula la mediana.
    public var window: TimeInterval
    /// Después de un desbloqueo no se bloquea durante este tiempo.
    public var unlockGrace: TimeInterval

    public init(
        lockRSSI: Int = -80,
        nearRSSI: Int = -60,
        lockDelay: TimeInterval = 5,
        lostTimeout: TimeInterval = 30,
        nearHold: TimeInterval = 2,
        window: TimeInterval = 4,
        unlockGrace: TimeInterval = 20
    ) {
        self.lockRSSI = lockRSSI
        self.nearRSSI = nearRSSI
        self.lockDelay = lockDelay
        self.lostTimeout = lostTimeout
        self.nearHold = nearHold
        self.window = window
        self.unlockGrace = unlockGrace
    }
}

public enum PresenceState: Equatable {
    /// Estás en la compu. Solo desde acá se puede bloquear.
    case present
    /// La señal está floja; si sigue así `lockDelay` segundos, se bloquea.
    case leaving(since: Date)
    /// Te fuiste (o todavía no te vimos cerca). No se vuelve a bloquear hasta que
    /// la señal supere `nearRSSI`: esto es lo que corta el bucle con el Apple Watch.
    case away
}

public enum LockReason: Equatable {
    case away
    case signalLost
}

public enum PresenceEvent: Equatable {
    case lock(LockReason)
    case returned
}

/// Decide cuándo bloquear a partir de lecturas de señal Bluetooth.
///
/// No sabe nada de Bluetooth ni de la pantalla: recibe lecturas con su hora y
/// devuelve eventos. Arranca en `.away` a propósito, así nunca bloquea hasta
/// haberte visto cerca al menos una vez.
public final class PresenceEngine {
    public var config: PresenceConfig
    public private(set) var state: PresenceState = .away
    public private(set) var lastSampleAt: Date?

    private var samples: [(at: Date, rssi: Int)] = []
    private var nearSince: Date?
    private var noLockBefore: Date = .distantPast

    public init(config: PresenceConfig = PresenceConfig()) {
        self.config = config
    }

    /// Mediana de las lecturas recientes. La mediana ignora picos sueltos,
    /// que en Bluetooth son muy comunes.
    public var smoothedRSSI: Int? {
        guard !samples.isEmpty else { return nil }
        let sorted = samples.map(\.rssi).sorted()
        let mid = sorted.count / 2
        return sorted.count % 2 == 1 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
    }

    public func isLost(at now: Date) -> Bool {
        guard let last = lastSampleAt else { return true }
        return now.timeIntervalSince(last) > config.lostTimeout
    }

    public func add(rssi: Int, at now: Date) -> [PresenceEvent] {
        // CoreBluetooth devuelve 127 cuando no pudo medir.
        if rssi < 0 {
            samples.append((now, rssi))
            lastSampleAt = now
        }
        return evaluate(at: now)
    }

    /// Avisa que la pantalla se desbloqueó (por el reloj, Touch ID o contraseña).
    public func userUnlocked(at now: Date) {
        noLockBefore = now.addingTimeInterval(config.unlockGrace)
    }

    /// Olvida todo y queda esperando verte cerca, por ejemplo al despertar de reposo.
    public func reset() {
        state = .away
        samples.removeAll()
        lastSampleAt = nil
        nearSince = nil
    }

    /// Llamar periódicamente (una vez por segundo alcanza) además de en cada lectura,
    /// para que los tiempos avancen aunque no lleguen lecturas.
    public func evaluate(at now: Date) -> [PresenceEvent] {
        samples.removeAll { now.timeIntervalSince($0.at) > config.window }
        let lost = isLost(at: now)
        let rssi = smoothedRSSI
        // Sin lecturas en la ventana pero sin llegar a "perdido" no decidimos nada:
        // el reloj a veces pasa unos segundos sin anunciarse.
        let weak = rssi.map { $0 < config.lockRSSI } ?? false
        let strong = rssi.map { $0 >= config.lockRSSI } ?? false

        switch state {
        case .present:
            if lost { return lock(.signalLost, at: now) }
            if weak { state = .leaving(since: now) }
            return []

        case .leaving(let since):
            if lost { return lock(.signalLost, at: now) }
            if strong {
                state = .present
                return []
            }
            if now.timeIntervalSince(since) >= config.lockDelay { return lock(.away, at: now) }
            return []

        case .away:
            guard !lost, let rssi, rssi >= config.nearRSSI else {
                nearSince = nil
                return []
            }
            let since = nearSince ?? now
            nearSince = since
            guard now.timeIntervalSince(since) >= config.nearHold else { return [] }
            state = .present
            nearSince = nil
            return [.returned]
        }
    }

    private func lock(_ reason: LockReason, at now: Date) -> [PresenceEvent] {
        // Durante la gracia post-desbloqueo no bloqueamos, pero tampoco cambiamos de
        // estado: si seguís lejos cuando termina, se bloquea en ese momento.
        guard now >= noLockBefore else { return [] }
        state = .away
        nearSince = nil
        return [.lock(reason)]
    }
}
