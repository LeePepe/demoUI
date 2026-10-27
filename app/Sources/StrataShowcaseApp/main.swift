import Foundation
import StrataShowcase
import SwiftUI

#if os(macOS)
import AppKit
import Darwin
#endif

@main
struct StrataShowcaseApp: App {
    private let exportDirectory: URL?
    private let launchConfiguration: StrataShowcaseConfiguration?
    private let launchError: String?

    init() {
        do {
            launchConfiguration = try StrataShowcaseConfiguration()
            launchError = nil
        } catch {
            launchConfiguration = nil
            launchError = String(describing: error)
        }
        if let index = CommandLine.arguments.firstIndex(of: "--export-screenshots"),
           CommandLine.arguments.indices.contains(index + 1) {
            exportDirectory = URL(fileURLWithPath: CommandLine.arguments[index + 1], isDirectory: true)
        } else {
            exportDirectory = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let exportDirectory {
                Color.clear
                    .task {
                        await exportScreenshots(to: exportDirectory)
                    }
            } else if let launchConfiguration {
                StrataShowcaseRootView(configuration: launchConfiguration)
            } else {
                Text(launchError ?? "Unable to resolve showcase configuration.")
                    .padding()
            }
        }
        .defaultSize(width: 1200, height: 860)
    }

    @MainActor
    private func exportScreenshots(to directory: URL) async {
        #if os(macOS)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let screenshots: [(String, StrataShowcaseConfiguration)] = [
                ("showcase-overview-blue-light", try StrataShowcaseConfiguration(
                    brand: .blue, appearance: .light, surfaceStyle: .solid, section: .overview
                )),
                ("showcase-overview-blue-dark", try StrataShowcaseConfiguration(
                    brand: .blue, appearance: .dark, surfaceStyle: .solid, section: .overview
                )),
                ("showcase-workout-blue-light", try StrataShowcaseConfiguration(
                    brand: .blue, appearance: .light, surfaceStyle: .glass, section: .workout
                )),
                ("showcase-picker-purple-dark", try StrataShowcaseConfiguration(
                    brand: .purple, appearance: .dark, surfaceStyle: .glass, section: .picker
                ))
            ]
            for (name, configuration) in screenshots {
                let content = StrataShowcaseRootView(
                    configuration: configuration,
                    rendersWithoutScrollView: true
                )
                    .frame(width: 1200, height: 860)
                let renderer = ImageRenderer(content: content)
                renderer.scale = 2
                guard let image = renderer.nsImage,
                      let tiff = image.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiff),
                      let png = bitmap.representation(using: .png, properties: [:]) else {
                    throw ScreenshotExportError.renderingFailed(name)
                }
                try png.write(to: directory.appendingPathComponent("\(name).png"))
            }
            exit(0)
        } catch {
            fputs("Screenshot export failed: \(error)\n", stderr)
            exit(1)
        }
        #else
        fputs("Screenshot export is supported on macOS only.\n", stderr)
        exit(1)
        #endif
    }
}

private enum ScreenshotExportError: Error, CustomStringConvertible {
    case renderingFailed(String)

    var description: String {
        switch self {
        case .renderingFailed(let name):
            "Unable to render \(name)"
        }
    }
}
