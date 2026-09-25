import SwiftUI

struct PanelView: View {
    @EnvironmentObject private var model: AppModel
    @AppStorage("settingsExpanded") private var settingsExpanded = false
    /// Fija si los ajustes se ven abiertos, sin tocar lo guardado (para las capturas).
    var settingsExpandedOverride: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatusCard()

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

            DeviceSection()

            SettingsSection(expanded: settingsExpandedOverride.map { .constant($0) } ?? $settingsExpanded)

            Divider()

            HStack {
                Text("AwayLock").font(.caption.weight(.medium))
                Text("0.1").font(.caption).foregroundStyle(.tertiary)
                Spacer()
                Button("Salir") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
                    .buttonStyle(.borderless)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 320)
        .animation(.easeInOut(duration: 0.2), value: model.hint)
        .onDisappear { model.deviceListOpen = false }
    }
}

// MARK: - Estado

private struct StatusCard: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let status = model.status
        VStack(alignment: .leading, spacing: 14) {
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
        .padding(12)
        .background(Card())
    }
}

/// Barra de señal con las dos zonas marcadas: a la izquierda del umbral rojo
/// bloquea, a la derecha del verde cuenta como que volviste.
private struct SignalMeter: View {
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

private struct HintBanner: View {
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

// MARK: - Acciones

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

// MARK: - Dispositivo

private struct DeviceSection: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader("Dispositivo")

            HoverRow {
                withAnimation(.easeInOut(duration: 0.2)) { model.deviceListOpen.toggle() }
            } content: {
                Image(systemName: "iphone").frame(width: 18)
                Text(model.deviceName).lineLimit(1)
                Spacer()
                Chevron(open: model.deviceListOpen)
            }

            if model.deviceListOpen {
                DeviceList()
                    .transition(.opacity)
            }
        }
    }
}

private struct DeviceList: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let devices = model.visibleDevices
        VStack(alignment: .leading, spacing: 2) {
            Text("Acercá \(model.showAllDevices ? "el dispositivo" : "tu iPhone") a la Mac: el de señal más fuerte va arriba.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)

            if let selected = model.selectedID, !devices.contains(where: { $0.id == selected }) {
                DeviceRow(name: model.deviceName, rssi: nil, selected: true) {}
            }

            if devices.isEmpty {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text(model.showAllDevices ? "Buscando…" : "Buscando iPhones…")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }

            ForEach(devices.prefix(12), id: \.id) { device in
                let fallback = device.isApple ? "Dispositivo Apple" : "Sin nombre"
                DeviceRow(name: device.name ?? fallback, rssi: device.rssi, selected: device.id == model.selectedID) {
                    model.select(device.id)
                }
            }

            HStack {
                Toggle("Mostrar todos", isOn: $model.showAllDevices)
                    .toggleStyle(.checkbox)
                Spacer()
                if model.selectedID != nil {
                    Button("Quitar dispositivo") { model.select(nil) }
                        .buttonStyle(.link)
                }
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
        .background(Card())
    }
}

private struct DeviceRow: View {
    let name: String
    let rssi: Int?
    let selected: Bool
    let action: () -> Void

    /// De -95 dBm (nada) a -40 dBm (barras llenas).
    private var bars: Double {
        guard let rssi else { return 0 }
        return min(max(Double(rssi + 95) / 55, 0), 1)
    }

    var body: some View {
        HoverRow(action: action) {
            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentColor)
                .opacity(selected ? 1 : 0)
                .frame(width: 14)
            Text(name).lineLimit(1)
            Spacer()
            if let rssi {
                Text("\(rssi) dBm")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Image(systemName: "cellularbars", variableValue: bars)
                    .foregroundStyle(.secondary)
            } else {
                Text("fuera de alcance")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Ajustes

private struct SettingsSection: View {
    @EnvironmentObject private var model: AppModel
    @Binding var expanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HoverRow {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } content: {
                Image(systemName: "slider.horizontal.3").frame(width: 18)
                Text("Ajustes")
                Spacer()
                Chevron(open: expanded)
            }

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    ThresholdSlider(
                        title: "Bloquear con señal menor a", dot: .red,
                        value: Binding(get: { model.lockRSSI }, set: { model.lockRSSI = $0 }),
                        range: -95 ... -65
                    )
                    ThresholdSlider(
                        title: "Volviste con señal mayor a", dot: .green,
                        value: Binding(get: { model.nearRSSI }, set: { model.nearRSSI = $0 }),
                        range: -75 ... -40
                    )

                    Divider()

                    PickerRow(title: "Demora antes de bloquear", selection: $model.lockDelay, options: [3, 5, 10, 20, 30])
                    PickerRow(title: "Sin señal, bloquear a los", selection: $model.lostTimeout, options: [15, 30, 60, 120])

                    Divider()

                    ToggleRow(title: "Despertar la pantalla al volver", isOn: $model.wakeOnReturn)
                    ToggleRow(title: "Solo escuchar (sin conectarse)", isOn: $model.passive)
                    ToggleRow(title: "Abrir al iniciar sesión", isOn: $model.launchAtLogin)
                }
                .padding(12)
                .background(Card())
                .transition(.opacity)
            }
        }
    }
}

private struct ThresholdSlider: View {
    let title: String
    let dot: Color
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle().fill(dot).frame(width: 6, height: 6)
                Text(title).font(.callout)
                Spacer()
                Text("\(value) dBm")
                    .font(.callout)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }),
                in: Double(range.lowerBound) ... Double(range.upperBound),
                step: 5
            )
            .controlSize(.small)
        }
    }
}

private struct PickerRow: View {
    let title: String
    @Binding var selection: Int
    let options: [Int]

    var body: some View {
        HStack {
            Text(title).font(.callout)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { Text("\($0) s").tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .fixedSize()
            .controlSize(.small)
        }
    }
}

private struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title).font(.callout)
        }
        .toggleStyle(.switch)
        .controlSize(.mini)
    }
}

// MARK: - Piezas comunes

private struct Card: View {
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

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
    }
}

private struct Chevron: View {
    let open: Bool

    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .rotationEffect(.degrees(open ? 90 : 0))
    }
}

/// Fila clickeable que se resalta al pasar el mouse, como un ítem de menú.
private struct HoverRow<Content: View>: View {
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
