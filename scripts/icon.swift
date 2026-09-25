// Dibuja el ícono de AwayLock a 1024×1024. Lo usa scripts/make-icon.sh.
// Uso: swift scripts/icon.swift salida.png
import AppKit
import SwiftUI

/// Candado en el centro de ondas de radar: "se bloquea según la distancia".
/// Sigue la grilla de íconos de macOS: cuadrado redondeado de 824 pt dentro de un lienzo de 1024.
struct AppIcon: View {
    private let side: CGFloat = 824
    private let radius: CGFloat = 185

    var body: some View {
        ZStack {
            // Fondo: el mismo violeta del README, más claro arriba.
            LinearGradient(
                colors: [Color(red: 0.42, green: 0.36, blue: 0.96), Color(red: 0.19, green: 0.13, blue: 0.52)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Ondas de radar, cada vez más tenues hacia afuera.
            ForEach(0 ..< 3) { ring in
                Circle()
                    .stroke(Color.white.opacity(0.24 - Double(ring) * 0.07), lineWidth: 16)
                    .frame(width: 430 + CGFloat(ring) * 170)
            }

            // El iPhone: un punto verde sobre la segunda onda.
            Circle()
                .fill(Color(red: 0.30, green: 0.87, blue: 0.47))
                .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 8))
                .frame(width: 64, height: 64)
                .offset(x: 300 * cos(-.pi / 4), y: 300 * sin(-.pi / 4))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

            Image(systemName: "lock.fill")
                .font(.system(size: 290, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.white, Color(white: 0.86)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.3), radius: 18, y: 10)

            // Brillo sutil arriba para darle volumen.
            LinearGradient(colors: [.white.opacity(0.18), .clear], startPoint: .top, endPoint: .center)
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.3), radius: 22, y: 12)
        .frame(width: 1024, height: 1024)
    }
}

MainActor.assumeIsolated {
    let output = CommandLine.arguments.dropFirst().first ?? "icon.png"
    let renderer = ImageRenderer(content: AppIcon())
    renderer.scale = 1
    guard let image = renderer.cgImage else {
        print("✗ no se pudo dibujar el ícono")
        exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else { exit(1) }
    try! data.write(to: URL(fileURLWithPath: output))
    print("✓ \(output)")
}
