import AppKit
import SwiftUI

/// La ventana "de app normal". Mientras está abierta, AwayLock aparece en el Dock
/// y en el selector de apps; al cerrarla vuelve a vivir solo en la barra de menú.
@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {
    private unowned let model: AppModel
    private var window: NSWindow?

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: MainWindowView().environmentObject(model))
            let window = NSWindow(contentViewController: hosting)
            window.title = "AwayLock"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            window.setFrameAutosaveName("AwayLockMainWindow")
            self.window = window
        }
        // La lista de dispositivos escanea solo mientras la ventana está abierta.
        model.isListingDevices = true
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        model.isListingDevices = false
        NSApp.setActivationPolicy(.accessory)
        // Soltamos la ventana para que no quede en memoria redibujándose oculta.
        DispatchQueue.main.async { [weak self] in self?.window = nil }
    }
}

struct MainWindowView: View {
    @EnvironmentObject private var model: AppModel
    var height: CGFloat = 720

    var body: some View {
        Form {
            Section {
                AppHeader()
                StatusCard(framed: false)
                if model.needsBluetoothPermission {
                    PermissionBanner { model.openBluetoothSettings() }
                }
                if let hint = model.hint {
                    HintBanner(text: hint) { model.hint = nil }
                }
            }

            Section {
                DeviceList()
            } header: {
                Text("Dispositivo")
            } footer: {
                Text("Acercá tu iPhone a la Mac: el de señal más fuerte aparece primero.")
                    .foregroundStyle(.secondary)
            }

            Section {
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
            } header: {
                Text("Distancia")
            } footer: {
                Text("Sentado frente a la Mac, el punto del medidor debería quedar en la zona verde. Donde quieras que se bloquee, en la roja.")
                    .foregroundStyle(.secondary)
            }

            Section("Tiempos") {
                Picker("Demora antes de bloquear", selection: $model.lockDelay) {
                    ForEach([3, 5, 10, 20, 30], id: \.self) { Text("\($0) s").tag($0) }
                }
                Picker("Sin señal, bloquear a los", selection: $model.lostTimeout) {
                    ForEach([15, 30, 60, 120], id: \.self) { Text("\($0) s").tag($0) }
                }
            }

            Section("Opciones") {
                Toggle(isOn: $model.enabled) {
                    Text("Bloquear automáticamente")
                    Text("Pausalo cuando no lo necesites.")
                }
                Toggle(isOn: $model.wakeOnReturn) {
                    Text("Despertar la pantalla al volver")
                    Text("Así tu Apple Watch te desbloquea apenas llegás.")
                }
                Toggle(isOn: $model.passive) {
                    Text("Solo escuchar (sin conectarse)")
                    Text("Usalo si notás interferencias con otros accesorios Bluetooth.")
                }
                Toggle(isOn: $model.launchAtLogin) {
                    Text("Abrir al iniciar sesión")
                    Text("AwayLock arranca solo cada vez que entrás a la Mac.")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: height)
        .onAppear { model.viewAppeared() }
        .onDisappear { model.viewDisappeared() }
    }
}

private struct AppHeader: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text("AwayLock").font(.title2.weight(.semibold))
                Text("Tu Mac se bloquea sola cuando te alejás con el iPhone.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DeviceList: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let devices = model.visibleDevices

        if let selected = model.selectedID, !devices.contains(where: { $0.id == selected }) {
            DeviceRow(name: model.deviceName, rssi: nil, selected: true) {}
        }

        if devices.isEmpty {
            HStack(spacing: 8) {
                ProgressView().controlSize(.small)
                Text(model.showAllDevices ? "Buscando…" : "Buscando iPhones…")
                    .foregroundStyle(.secondary)
            }
        }

        ForEach(devices.prefix(12), id: \.id) { device in
            let fallback = device.isApple ? "Dispositivo Apple" : "Sin nombre"
            DeviceRow(name: device.name ?? fallback, rssi: device.rssi, selected: device.id == model.selectedID) {
                model.select(device.id)
            }
        }

        HStack {
            Toggle("Mostrar todos los dispositivos", isOn: $model.showAllDevices)
                .toggleStyle(.checkbox)
            Spacer()
            if model.selectedID != nil {
                Button("Quitar dispositivo") { model.select(nil) }
            }
        }
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
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "iphone")
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                Text(name)
                Spacer()
                if let rssi {
                    Text("\(rssi) dBm")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    Image(systemName: "cellularbars", variableValue: bars)
                        .foregroundStyle(.secondary)
                } else {
                    Text("fuera de alcance")
                        .foregroundStyle(.tertiary)
                }
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .opacity(selected ? 1 : 0)
                    .frame(width: 16)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
