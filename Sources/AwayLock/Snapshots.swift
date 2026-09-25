#if DEBUG
import AppKit
import SwiftUI

/// Dibuja el panel real con datos de ejemplo y lo guarda como PNG para el README.
/// No necesita permiso de grabación de pantalla: la app se dibuja a sí misma.
@MainActor
enum Snapshots {
    static func render(to folder: URL) {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.prohibited)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let shots: [(String, AnyView)] = [
            ("estados.png", AnyView(Showcase(panels: [
                .init(caption: "Estás en la compu", model: .preview(.near)),
                .init(caption: "Te levantás y te vas", model: .preview(.leaving)),
                .init(caption: "La Mac queda bloqueada", model: .preview(.away)),
            ]))),
            ("dispositivo.png", AnyView(Showcase(panels: [
                .init(caption: "Elegís tu iPhone", model: .preview(.near, devices: true)),
            ]))),
            ("ajustes.png", AnyView(Showcase(panels: [
                .init(caption: "Lo ajustás a tu escritorio", model: .preview(.near), settingsExpanded: true),
            ]))),
        ]
        for (name, view) in shots {
            let url = folder.appendingPathComponent(name)
            if write(view, to: url) {
                print("✓ \(url.path)")
            } else {
                print("✗ no se pudo generar \(name)")
            }
        }
    }

    private static func write(_ view: AnyView, to url: URL) -> Bool {
        let host = NSHostingView(rootView: view.environment(\.colorScheme, .dark))
        host.appearance = NSAppearance(named: .darkAqua)
        host.frame = CGRect(origin: .zero, size: host.fittingSize)

        let window = NSWindow(contentRect: host.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        // Un instante para que SwiftUI termine de dibujar.
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return false }
        host.cacheDisplay(in: host.bounds, to: rep)
        guard let data = rep.representation(using: .png, properties: [:]) else { return false }
        return (try? data.write(to: url)) != nil
    }
}

private struct ShowcasePanel {
    let caption: String
    let model: AppModel
    var settingsExpanded = false
}

/// Paneles sobre un fondo de color, con una leyenda abajo de cada uno.
private struct Showcase: View {
    let panels: [ShowcasePanel]

    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            ForEach(panels.indices, id: \.self) { index in
                let panel = panels[index]
                VStack(spacing: 18) {
                    FramedPanel(model: panel.model, settingsExpanded: panel.settingsExpanded)
                    Text(panel.caption)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 48)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.42),
                    Color(red: 0.36, green: 0.20, blue: 0.48),
                    Color(red: 0.10, green: 0.32, blue: 0.44),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

/// El panel con el fondo y el borde que le da la barra de menú.
private struct FramedPanel: View {
    @ObservedObject var model: AppModel
    let settingsExpanded: Bool

    var body: some View {
        PanelView(settingsExpandedOverride: settingsExpanded)
            .environmentObject(model)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.14).opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12))
            )
            .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
    }
}
#endif
