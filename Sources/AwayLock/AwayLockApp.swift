import SwiftUI

@main
enum Main {
    @MainActor
    static func main() {
        #if DEBUG
        // `swift run AwayLock --snapshots docs` genera las imágenes del README.
        if let flag = CommandLine.arguments.firstIndex(of: "--snapshots") {
            let arguments = CommandLine.arguments
            let folder = arguments.indices.contains(flag + 1) ? arguments[flag + 1] : "docs"
            Snapshots.render(to: URL(fileURLWithPath: folder))
            return
        }
        #endif
        AwayLockApp.main()
    }
}

struct AwayLockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel.shared

    var body: some Scene {
        MenuBarExtra {
            PanelView()
                .environmentObject(model)
        } label: {
            Image(systemName: model.menuBarSymbol)
        }
        // Panel tipo Centro de Control en vez de un menú de texto.
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // La primera vez, sin iPhone elegido, mostramos la ventana para configurarlo.
        if AppModel.shared.selectedID == nil {
            AppModel.shared.openMainWindow()
        }
    }

    /// Abrir la app desde el Finder, Launchpad o el Dock mientras ya está corriendo.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        AppModel.shared.openMainWindow()
        return false
    }
}
