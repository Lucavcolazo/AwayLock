import SwiftUI

/// Panel de la barra de menú: solo el estado y lo de todos los días.
/// El dispositivo y los ajustes viven en la ventana principal.
struct PanelView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatusCard()

            if model.needsBluetoothPermission {
                PermissionBanner { model.openBluetoothSettings() }
            }

            if let hint = model.hint {
                HintBanner(text: hint) { model.hint = nil }
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack(spacing: 8) {
                Tile(
                    symbol: model.enabled ? "power" : "pause.fill",
                    title: model.enabled ? "Activado" : "En pausa",
                    isOn: model.enabled
                ) { model.enabled.toggle() }
                Tile(symbol: "lock.fill", title: "Bloquear", isOn: false) { model.lockNow() }
            }

            HoverRow {
                model.openMainWindow()
            } content: {
                Image(systemName: "gearshape").frame(width: 18)
                Text("Dispositivo y ajustes…")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Text("AwayLock").font(.caption.weight(.medium))
                Text(AppModel.version).font(.caption).foregroundStyle(.tertiary)
                Spacer()
                Button("Salir") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
                    .buttonStyle(.borderless)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 300)
        .animation(.easeInOut(duration: 0.2), value: model.hint)
        .onAppear { model.viewAppeared() }
        .onDisappear { model.viewDisappeared() }
    }
}

/// Botón grande estilo Centro de Control.
private struct Tile: View {
    let symbol: String
    let title: String
    let isOn: Bool
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(isOn ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(Color.primary.opacity(0.1)))
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isOn ? .white : .primary)
                }
                .frame(width: 26, height: 26)
                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(8)
            .contentShape(Rectangle())
            .background(Card(highlighted: hovering))
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}
