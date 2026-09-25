import AwayLockCore
import Foundation

final class Preferences {
    private static let fallback: [String: Any] = [
        "enabled": true,
        "lockRSSI": -80,
        "nearRSSI": -60,
        "lockDelay": 5.0,
        "lostTimeout": 30.0,
        "wakeOnReturn": true,
        "passive": false,
    ]

    private let defaults: UserDefaults?
    private var memory: [String: Any] = [:]

    /// `inMemory: true` no lee ni escribe en disco: sirve para las capturas.
    init(inMemory: Bool = false) {
        defaults = inMemory ? nil : .standard
        defaults?.register(defaults: Self.fallback)
    }

    private func value(_ key: String) -> Any? {
        if let defaults { return defaults.object(forKey: key) }
        return memory[key] ?? Self.fallback[key]
    }

    private func store(_ value: Any?, _ key: String) {
        if let defaults {
            defaults.set(value, forKey: key)
        } else {
            memory[key] = value
        }
    }

    var enabled: Bool {
        get { value("enabled") as? Bool ?? true }
        set { store(newValue, "enabled") }
    }

    var deviceID: UUID? {
        get { (value("deviceID") as? String).flatMap(UUID.init(uuidString:)) }
        set { store(newValue?.uuidString, "deviceID") }
    }

    var deviceName: String? {
        get { value("deviceName") as? String }
        set { store(newValue, "deviceName") }
    }

    var lockRSSI: Int {
        get { value("lockRSSI") as? Int ?? -80 }
        set { store(newValue, "lockRSSI") }
    }

    var nearRSSI: Int {
        get { value("nearRSSI") as? Int ?? -60 }
        set { store(newValue, "nearRSSI") }
    }

    var lockDelay: TimeInterval {
        get { value("lockDelay") as? Double ?? 5 }
        set { store(newValue, "lockDelay") }
    }

    var lostTimeout: TimeInterval {
        get { value("lostTimeout") as? Double ?? 30 }
        set { store(newValue, "lostTimeout") }
    }

    var wakeOnReturn: Bool {
        get { value("wakeOnReturn") as? Bool ?? true }
        set { store(newValue, "wakeOnReturn") }
    }

    var passive: Bool {
        get { value("passive") as? Bool ?? false }
        set { store(newValue, "passive") }
    }

    var config: PresenceConfig {
        PresenceConfig(lockRSSI: lockRSSI, nearRSSI: nearRSSI, lockDelay: lockDelay, lostTimeout: lostTimeout)
    }
}
