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

        // Para que el encabezado de la ventana muestre el ícono real.
        if let icon = NSImage(contentsOfFile: "Resources/AppIcon.icns") {
            NSApp.applicationIconImage = icon
        }

        let shots: [(String, AnyView)] = [
            ("estados.png", AnyView(Showcase(items: [
                .init(caption: "Estás en la compu", content: AnyView(FramedPanel(model: .preview(.near)))),
                .init(caption: "Te levantás y te vas", content: AnyView(FramedPanel(model: .preview(.leaving)))),
                .init(caption: "La Mac queda bloqueada", content: AnyView(FramedPanel(model: .preview(.away)))),
            ]))),
            ("ventana.png", AnyView(Showcase(items: [
                .init(caption: "Tu iPhone y los ajustes, en su propia ventana",
                      content: AnyView(FramedWindow(model: .preview(.near, devices: true)))),
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

private struct ShowcaseItem {
    let caption: String
    let content: AnyView
}

/// Capturas sobre un fondo de color, con una leyenda abajo de cada una.
private struct Showcase: View {
    let items: [ShowcaseItem]

    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            ForEach(items.indices, id: \.self) { index in
                VStack(spacing: 18) {
                    items[index].content
                    Text(items[index].caption)
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

    var body: some View {
        PanelView()
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

/// La ventana principal con una barra de título dibujada (la real no se captura).
private struct FramedWindow: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 8) {
                    Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.34))
                    Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18))
                    Circle().fill(Color(red: 0.16, green: 0.79, blue: 0.25))
                    Spacer()
                }
                .frame(height: 12)
                .padding(.leading, 14)
                Text("AwayLock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 30)
            .background(Color(white: 0.19))

            MainWindowView(height: 1030)
                .environmentObject(model)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12))
        )
        .shadow(color: .black.opacity(0.4), radius: 28, y: 14)
    }
}
#endif
