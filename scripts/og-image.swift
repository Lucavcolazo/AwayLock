// Dibuja la imagen de vista previa de la landing (1200×630), la que muestran X y
// otras redes al pegar el link. Uso: swift scripts/og-image.swift site/assets/og.png
import AppKit
import SwiftUI

struct OGImage: View {
    let icon: NSImage?

    var body: some View {
        ZStack(alignment: .leading) {
            Color(red: 0.04, green: 0.03, blue: 0.09)

            // Brillo violeta y ondas de radar a la derecha, como en la portada.
            RadialGradient(
                colors: [Color(red: 0.48, green: 0.42, blue: 1).opacity(0.55), .clear],
                center: UnitPoint(x: 0.82, y: 0.5), startRadius: 0, endRadius: 420
            )
            ZStack {
                Circle().stroke(Color.white.opacity(0.1), lineWidth: 2).frame(width: 560)
                Circle().stroke(Color(red: 1, green: 0.36, blue: 0.42).opacity(0.8),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [4, 12])).frame(width: 400)
                Circle().stroke(Color(red: 0.29, green: 0.87, blue: 0.5).opacity(0.85),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [4, 12])).frame(width: 240)
                if let icon {
                    Image(nsImage: icon).resizable().frame(width: 150, height: 150)
                        .shadow(color: Color(red: 0.23, green: 0.16, blue: 0.62).opacity(0.9), radius: 30, y: 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .offset(x: 150)

            VStack(alignment: .leading, spacing: 22) {
                Text("AwayLock")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(red: 0.62, green: 0.57, blue: 1))
                Text("Tu Mac se bloquea sola\ncuando te alejás.")
                    .font(.system(size: 68, weight: .heavy))
                    .tracking(-2)
                    .lineSpacing(-4)
                    .foregroundStyle(.white)
                Text("Gratis · código abierto · no toca tu contraseña")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color(red: 0.76, green: 0.74, blue: 0.89))
            }
            .padding(.leading, 80)
        }
        .frame(width: 1200, height: 630)
        .clipped()
    }
}

MainActor.assumeIsolated {
    let output = CommandLine.arguments.dropFirst().first ?? "og.png"
    let icon = NSImage(contentsOfFile: "site/assets/icon-512.png")
    let renderer = ImageRenderer(content: OGImage(icon: icon))
    renderer.scale = 1
    guard let image = renderer.cgImage,
          let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
    else {
        print("✗ no se pudo dibujar la imagen")
        exit(1)
    }
    try! data.write(to: URL(fileURLWithPath: output))
    print("✓ \(output)")
}
