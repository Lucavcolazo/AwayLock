import SwiftUI

@main
struct AwayLockApp: App {
    @StateObject private var model = AppModel()

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
