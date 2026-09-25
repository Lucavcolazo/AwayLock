// Genera el video promocional (1920×1080, 60 fps, 15 s) a partir de promo/index.html.
// Dibuja cada cuadro con renderAt(t), lo captura con WebKit y se lo pasa a ffmpeg.
//
// Uso (con la promo servida en http://localhost:4174, ver scripts/render-promo.sh):
//   swift scripts/render-promo.swift dist/awaylock-promo.mp4
//   swift scripts/render-promo.swift --test carpeta/   (solo algunos cuadros, en PNG)
import AppKit
import WebKit

let args = Array(CommandLine.arguments.dropFirst())
let testMode = args.first == "--test"
let output = testMode ? (args.dropFirst().first ?? ".") : (args.first ?? "awaylock-promo.mp4")
let url = URL(string: ProcessInfo.processInfo.environment["PROMO_URL"] ?? "http://localhost:4174/promo/?render")!
let fps = 60.0
let duration = 15.0
let size = CGSize(width: 1920, height: 1080)

func pngData(_ image: NSImage) -> Data? {
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
    return rep.representation(using: .png, properties: [:])
}

@MainActor
func run() async throws {
    let web = WKWebView(frame: CGRect(origin: .zero, size: size))
    // Ventana fuera de la pantalla: WebKit necesita una para dibujar, pero no se ve.
    let window = NSWindow(contentRect: CGRect(origin: CGPoint(x: -30000, y: -30000), size: size),
                          styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = web
    window.orderFront(nil)

    web.load(URLRequest(url: url))
    while web.isLoading { try await Task.sleep(for: .milliseconds(100)) }
    _ = try await web.callAsyncJavaScript("await document.fonts.ready; return 1", contentWorld: .page)
    try await Task.sleep(for: .milliseconds(600))

    let times: [Double] = testMode
        ? [0.5, 1.9, 3.5, 4.4, 6.7, 7.9, 9.9, 11.8, 13.4, 14.9]
        : (0..<Int(duration * fps)).map { Double($0) / fps }

    var ffmpeg: Process?
    var pipe: Pipe?
    if !testMode {
        let p = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        process.arguments = [
            "-y", "-loglevel", "error",
            "-f", "image2pipe", "-framerate", "\(Int(fps))", "-c:v", "png", "-i", "-",
            "-vf", "scale=1920:1080:flags=lanczos,format=yuv420p",
            "-c:v", "libx264", "-preset", "slow", "-crf", "16", "-r", "\(Int(fps))",
            "-movflags", "+faststart", output,
        ]
        process.standardInput = p
        try process.run()
        ffmpeg = process
        pipe = p
    }

    let started = Date()
    for (index, t) in times.enumerated() {
        _ = try await web.callAsyncJavaScript("renderAt(t); return 1", arguments: ["t": t], contentWorld: .page)
        let image = try await web.takeSnapshot(configuration: nil)
        guard let data = pngData(image) else { throw NSError(domain: "render", code: 1) }
        if testMode {
            let path = "\(output)/frame-\(String(format: "%05.2f", t)).png"
            try data.write(to: URL(fileURLWithPath: path))
            print("✓ \(path)")
        } else {
            pipe!.fileHandleForWriting.write(data)
            if index % 60 == 0 {
                print(String(format: "cuadro %d/%d (%.0f s)", index, times.count, Date().timeIntervalSince(started)))
            }
        }
    }

    if let pipe, let ffmpeg {
        try pipe.fileHandleForWriting.close()
        ffmpeg.waitUntilExit()
        print(ffmpeg.terminationStatus == 0 ? "✓ \(output)" : "✗ ffmpeg terminó con error \(ffmpeg.terminationStatus)")
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
Task { @MainActor in
    do {
        try await run()
        exit(0)
    } catch {
        print("✗ \(error)")
        exit(1)
    }
}
app.run()
