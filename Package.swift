// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "AwayLock",
    platforms: [.macOS(.v13)],
    targets: [
        // Lógica pura de "¿estás o no estás?", sin Bluetooth ni AppKit, para poder testearla.
        .target(name: "AwayLockCore"),
        // App de barra de menú: Bluetooth, bloqueo de pantalla y menú.
        .executableTarget(name: "AwayLock", dependencies: ["AwayLockCore"]),
        .testTarget(name: "AwayLockCoreTests", dependencies: ["AwayLockCore"]),
    ]
)
