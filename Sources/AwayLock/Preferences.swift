import AwayLockCore
import Foundation

final class Preferences {
    private let defaults = UserDefaults.standard

    init() {
        defaults.register(defaults: [
            "enabled": true,
            "lockRSSI": -80,
            "nearRSSI": -60,
            "lockDelay": 5.0,
            "lostTimeout": 30.0,
            "wakeOnReturn": true,
            "passive": false,
        ])
    }

    var enabled: Bool {
        get { defaults.bool(forKey: "enabled") }
        set { defaults.set(newValue, forKey: "enabled") }
    }

    var deviceID: UUID? {
        get { defaults.string(forKey: "deviceID").flatMap(UUID.init(uuidString:)) }
        set { defaults.set(newValue?.uuidString, forKey: "deviceID") }
    }

    var deviceName: String? {
        get { defaults.string(forKey: "deviceName") }
        set { defaults.set(newValue, forKey: "deviceName") }
    }

    var lockRSSI: Int {
        get { defaults.integer(forKey: "lockRSSI") }
        set { defaults.set(newValue, forKey: "lockRSSI") }
    }

    var nearRSSI: Int {
        get { defaults.integer(forKey: "nearRSSI") }
        set { defaults.set(newValue, forKey: "nearRSSI") }
    }

    var lockDelay: TimeInterval {
        get { defaults.double(forKey: "lockDelay") }
        set { defaults.set(newValue, forKey: "lockDelay") }
    }

    var lostTimeout: TimeInterval {
        get { defaults.double(forKey: "lostTimeout") }
        set { defaults.set(newValue, forKey: "lostTimeout") }
    }

    var wakeOnReturn: Bool {
        get { defaults.bool(forKey: "wakeOnReturn") }
        set { defaults.set(newValue, forKey: "wakeOnReturn") }
    }

    var passive: Bool {
        get { defaults.bool(forKey: "passive") }
        set { defaults.set(newValue, forKey: "passive") }
    }

    var config: PresenceConfig {
        PresenceConfig(lockRSSI: lockRSSI, nearRSSI: nearRSSI, lockDelay: lockDelay, lostTimeout: lostTimeout)
    }
}
