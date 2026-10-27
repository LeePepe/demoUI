import Foundation
import XCTest

final class StrataSyncScriptTests: XCTestCase {
    private let originalSHA = "30112ae881314a525f3ffcb3913a3b02b8d6cbe6"
    private let replacementSHA = String(repeating: "a", count: 40)

    func testCheckPassesForRepositoryRoot() throws {
        let result = try runScript(["--check"], in: repositoryRoot)

        XCTAssertEqual(result.status, 0, result.output)
    }

    func testSHAUpdateIsAtomicAndIdempotentWithoutResolve() throws {
        let root = try makeFixture()
        defer { try? FileManager.default.removeItem(at: root) }

        let first = try runScript(
            ["--sha", replacementSHA, "--skip-resolve"],
            in: root
        )
        XCTAssertEqual(first.status, 0, first.output)
        XCTAssertEqual(try summary(from: first.output)["status"] as? String, "updated")
        XCTAssertEqual(try revision(in: root.appendingPathComponent(".github/repo-contract.json")), replacementSHA)
        XCTAssertTrue(
            try String(contentsOf: root.appendingPathComponent("app/Package.swift"))
                .contains("revision: \"\(replacementSHA)\"")
        )
        XCTAssertEqual(
            try revision(in: root.appendingPathComponent("app/Package.resolved")),
            replacementSHA
        )

        let second = try runScript(
            ["--sha", replacementSHA, "--skip-resolve"],
            in: root
        )
        XCTAssertEqual(second.status, 0, second.output)
        XCTAssertEqual(try summary(from: second.output)["status"] as? String, "noop")
    }

    func testCheckDetectsPackageDrift() throws {
        let root = try makeFixture()
        defer { try? FileManager.default.removeItem(at: root) }

        let packageURL = root.appendingPathComponent("app/Package.swift")
        let package = try String(contentsOf: packageURL)
        try package.replacingOccurrences(
            of: "revision: \"\(originalSHA)\"",
            with: "revision: \"\(replacementSHA)\""
        ).write(to: packageURL, atomically: true, encoding: .utf8)

        let result = try runScript(["--check"], in: root)

        XCTAssertEqual(result.status, 1, result.output)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func makeFixture() throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("strata-sync-\(UUID().uuidString)")
        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: root.appendingPathComponent("scripts"),
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: root.appendingPathComponent(".github"),
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: root.appendingPathComponent("app"),
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: root.appendingPathComponent("docs"),
            withIntermediateDirectories: true
        )

        let script = repositoryRoot.appendingPathComponent("scripts/sync-strata.py")
        try fileManager.copyItem(
            at: script,
            to: root.appendingPathComponent("scripts/sync-strata.py")
        )
        try """
        {
          "schema": 1,
          "guide": "docs/repository-guide.md",
          "shared_ci": "fd8a187ef4872aa1aa69c4e9afec9782183cc02d",
          "dependencies": {
            "shared-design-system": {
              "version": "\(originalSHA)",
              "ai": "https://github.com/LeePepe/shared-design-system/tree/\(originalSHA)/ai/"
            }
          }
        }
        """.write(
            to: root.appendingPathComponent(".github/repo-contract.json"),
            atomically: true,
            encoding: .utf8
        )
        try """
        let package = Package(
            dependencies: [
                .package(
                    url: "https://github.com/LeePepe/shared-design-system.git",
                    revision: "\(originalSHA)"
                )
            ]
        )
        """.write(
            to: root.appendingPathComponent("app/Package.swift"),
            atomically: true,
            encoding: .utf8
        )
        try """
        {
          "pins" : [
            {
              "identity" : "shared-design-system",
              "state" : {
                "revision" : "\(originalSHA)"
              }
            }
          ],
          "version" : 3
        }
        """.write(
            to: root.appendingPathComponent("app/Package.resolved"),
            atomically: true,
            encoding: .utf8
        )
        try "LeePepe/shared-design-system@\(originalSHA)\n## Complete shared protocol snapshot\nunchanged\n"
            .write(
                to: root.appendingPathComponent("docs/repository-guide.md"),
                atomically: true,
                encoding: .utf8
            )
        return root
    }

    private func runScript(_ arguments: [String], in root: URL) throws -> ScriptResult {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "scripts/sync-strata.py"] + arguments
        process.currentDirectoryURL = root
        var env = ProcessInfo.processInfo.environment
        for key in env.keys where key.hasPrefix("GIT_") {
            env.removeValue(forKey: key)
        }
        process.environment = env
        process.standardOutput = output
        process.standardError = output

        try process.run()
        process.waitUntilExit()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        return ScriptResult(
            status: process.terminationStatus,
            output: String(decoding: data, as: UTF8.self)
        )
    }

    private func summary(from output: String) throws -> [String: Any] {
        let line = try XCTUnwrap(output.split(separator: "\n").last)
        let data = Data(line.utf8)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func revision(in url: URL) throws -> String {
        let text = try String(contentsOf: url)
        let pattern = try NSRegularExpression(
            pattern: #""(?:version|revision)"\s*:\s*"([0-9a-f]{40})""#
        )
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let match = try XCTUnwrap(pattern.firstMatch(in: text, range: range))
        let revisionRange = match.range(at: 1)
        let stringRange = try XCTUnwrap(Range(revisionRange, in: text))
        return String(text[stringRange])
    }
}

private struct ScriptResult {
    let status: Int32
    let output: String
}
