import AppKit
import IOKit.pwr_mgt

enum ScreenControl {
    private typealias LockFunction = @convention(c) () -> Int32

    /// `SACLockScreenImmediate` es lo mismo que hace Ctrl+Cmd+Q. Es privada, así que
    /// la buscamos en tiempo de ejecución: si Apple la saca, la app sigue andando
    /// con el plan B en vez de no abrir.
    private static let lockScreenImmediate: LockFunction? = {
        let path = "/System/Library/PrivateFrameworks/login.framework/Versions/Current/login"
        guard let handle = dlopen(path, RTLD_LAZY),
              let symbol = dlsym(handle, "SACLockScreenImmediate")
        else { return nil }
        return unsafeBitCast(symbol, to: LockFunction.self)
    }()

    static func lock() {
        if let lockScreenImmediate, lockScreenImmediate() == 0 { return }
        // Plan B: apagar la pantalla. Bloquea solo si en Ajustes > Pantalla bloqueada
        // está "Pedir contraseña: inmediatamente".
        let pmset = Process()
        pmset.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        pmset.arguments = ["displaysleepnow"]
        try? pmset.run()
    }

    static var isLocked: Bool {
        guard let session = CGSessionCopyCurrentDictionary() as? [String: Any] else { return false }
        return (session["CGSSessionScreenIsLocked"] as? Bool) ?? false
    }

    /// Prende la pantalla como si hubieras tocado una tecla, lo que a su vez
    /// dispara el desbloqueo con Apple Watch.
    static func wakeDisplay() {
        var assertion: IOPMAssertionID = 0
        let result = IOPMAssertionDeclareUserActivity("AwayLock" as CFString, kIOPMUserActiveLocal, &assertion)
        guard result == kIOReturnSuccess else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            IOPMAssertionRelease(assertion)
        }
    }
}
