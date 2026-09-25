import SwiftUI

// Piezas que comparten el panel de la barra de menú y la ventana principal.

/// Ícono de estado, título, detalle y medidor de señal.
struct StatusCard: View {
    @EnvironmentObject private var model: AppModel
    /// En la ventana va dentro de una sección del formulario, que ya tiene su propio fondo.
    var framed = true

    var body: some View {
        let status = model.status
        let content = VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(status.tint.gradient)
                    Image(systemName: status.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(status.title).font(.headline)
                    Text(status.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .animation(.easeInOut(duration: 0.25), value: status.title)

            SignalMeter(rssi: model.rssi, lock: model.lockRSSI, near: model.nearRSSI, tint: status.tint)
        }

        if framed {
            content.padding(12).background(Card())
        } else {
            content.padding(.vertical, 4)
        }
    }
}

/// Barra de señal con las dos zonas marcadas: a la izquierda del umbral rojo
/// bloquea, a la derecha del verde cuenta como que volviste.
struct SignalMeter: View {
    let rssi: Int?
    let lock: Int
    let near: Int
    let tint: Color

    private let range = -100.0 ... -30.0

    private func x(_ value: Int, in width: CGFloat) -> CGFloat {
        let clamped = min(max(Double(value), range.lowerBound), range.upperBound)
        return CGFloat((clamped - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
    }

    var body: some View {
        VStack(spacing: 7) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Rectangle().fill(Color.red.opacity(0.35))
                            .frame(width: x(lock, in: width))
                        Rectangle().fill(Color.primary.opacity(0.12))
                            .frame(width: max(0, x(near, in: width) - x(lock, in: width)))
                        Rectangle().fill(Color.green.opacity(0.35))
                    }
                    .frame(height: 6)
                    .clipShape(Capsule())

                    if let rssi {
                        Circle()
                            .fill(.white)
                            .overlay(Circle().fill(tint).padding(3))
                            .shadow(color: .black.opacity(0.25), radius: 1.5, y: 0.5)
                            .frame(width: 14, height: 14)
                            .offset(x: x(rssi, in: width) - 7)
                    }
                }
                .frame(height: 14)
            }
            .frame(height: 14)

            HStack(spacing: 4) {
                Circle().fill(.red).frame(width: 5, height: 5)
                Text("Bloquea < \(lock)")
                Spacer()
                Text("Volviste > \(near)")
                Circle().fill(.green).frame(width: 5, height: 5)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .animation(.easeOut(duration: 0.4), value: rssi)
        .animation(.easeInOut(duration: 0.2), value: lock)
        .animation(.easeInOut(duration: 0.2), value: near)
    }
}

/// Aparece cuando macOS no le dio permiso de Bluetooth a la app.
struct PermissionBanner: View {
    let openSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.orange)
                Text("Para medir la señal de tu iPhone, AwayLock necesita acceso a Bluetooth.")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button("Abrir Ajustes", action: openSettings)
                .controlSize(.small)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.orange.opacity(0.15)))
    }
}

struct HintBanner: View {
    let text: String
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(text)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(action: dismiss) {
                Image(systemName: "xmark").font(.caption2.weight(.bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Descartar")
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.yellow.opacity(0.15)))
    }
}

/// Deslizador de umbral para el formulario: etiqueta a la izquierda con el valor debajo.
struct ThresholdSlider: View {
    let title: String
    let dot: Color
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        Slider(
            value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }),
            in: Double(range.lowerBound) ... Double(range.upperBound),
            step: 5
        ) {
            HStack(spacing: 8) {
                Circle().fill(dot).frame(width: 7, height: 7)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                    Text("\(value) dBm")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct Card: View {
    var highlighted = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.primary.opacity(highlighted ? 0.1 : 0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06))
            )
    }
}

/// Fila clickeable que se resalta al pasar el mouse, como un ítem de menú.
struct HoverRow<Content: View>: View {
    let action: () -> Void
    let content: Content
    @State private var hovering = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) { content }
                .font(.callout)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.primary.opacity(hovering ? 0.08 : 0))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
