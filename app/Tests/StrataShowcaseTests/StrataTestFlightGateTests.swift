import XCTest

final class StrataTestFlightGateTests: XCTestCase {
    func testTestFlightReleaseContractIsWired() throws {
        let repositoryRoot = self.repositoryRoot

        let exampleSigning = try String(
            contentsOf: repositoryRoot.appendingPathComponent("config/Signing.example.xcconfig"),
            encoding: .utf8
        )
        XCTAssertTrue(exampleSigning.contains("DEMOUI_BUNDLE_ID = com.example.demoui"))
        XCTAssertTrue(exampleSigning.contains("DEMOUI_TEAM_ID = ZZZZZZZZZZ"))
        XCTAssertTrue(exampleSigning.contains("DEMOUI_PROFILE_SPECIFIER = DemoUI App Store"))

        let project = try String(
            contentsOf: repositoryRoot.appendingPathComponent("app/project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("Signing.local.xcconfig"))
        XCTAssertTrue(project.contains("PRODUCT_BUNDLE_IDENTIFIER: \"$(DEMOUI_BUNDLE_ID)\""))
        XCTAssertTrue(project.contains("DEVELOPMENT_TEAM: \"$(DEMOUI_TEAM_ID)\""))
        XCTAssertTrue(project.contains("CODE_SIGN_STYLE: Automatic"))
        XCTAssertTrue(project.contains("CODE_SIGN_STYLE: Manual"))
        XCTAssertTrue(project.contains("CODE_SIGN_IDENTITY: Apple Distribution"))
        XCTAssertTrue(project.contains("PROVISIONING_PROFILE_SPECIFIER: $(DEMOUI_PROFILE_SPECIFIER)"))

        let workflow = try String(
            contentsOf: repositoryRoot.appendingPathComponent(".github/workflows/testflight.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(workflow.contains("workflows: [\"ci\"]"))
        XCTAssertTrue(workflow.contains("runs-on: [self-hosted, demoui-mac]"))
        XCTAssertTrue(
            workflow.contains(
                "github.event.pull_request == null || github.event.pull_request.head.repo.full_name == github.repository"
            )
        )
        XCTAssertTrue(workflow.contains("security unlock-keychain"))
        XCTAssertTrue(workflow.contains("security set-key-partition-list"))
        XCTAssertTrue(workflow.contains("brew list fastlane"))
        XCTAssertTrue(workflow.contains("brew list xcodegen"))
        XCTAssertTrue(workflow.contains("FASTLANE_SKIP_UPDATE_CHECK: \"1\""))
        XCTAssertTrue(workflow.contains("FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT: \"120\""))
        XCTAssertTrue(workflow.contains("FASTLANE_XCODEBUILD_SETTINGS_RETRIES: \"6\""))
        for variable in [
            "ASC_KEY_ID",
            "ASC_ISSUER_ID",
            "ASC_KEY_P8_BASE64",
            "KEYCHAIN_PASSWORD",
            "DEMOUI_BUNDLE_ID",
            "DEMOUI_TEAM_ID"
        ] {
            XCTAssertTrue(workflow.contains(variable), "missing \(variable)")
        }

        let fastlane = try String(
            contentsOf: repositoryRoot.appendingPathComponent("fastlane/Fastfile"),
            encoding: .utf8
        )
        XCTAssertTrue(fastlane.contains("repo_root = File.expand_path(\"..\", __dir__)"))
        XCTAssertTrue(fastlane.contains("in_house: false"))
        XCTAssertTrue(fastlane.contains("get_provisioning_profile"))
        XCTAssertTrue(fastlane.contains("latest_testflight_build_number"))
        XCTAssertTrue(fastlane.contains("signingStyle: \"manual\""))

        let contract = try runScript(
            ["--check-contract", "--dry-run"],
            in: repositoryRoot
        )
        XCTAssertEqual(contract.status, 0, contract.output)
        XCTAssertEqual(
            try jsonLines(from: contract.output).first?["contract"] as? String,
            "ok"
        )

        let fixture = try makeGateFixture()
        defer { try? FileManager.default.removeItem(at: fixture) }

        try commit("README.md", contents: "docs\n", in: fixture)
        let docsOnly = try runScript(["--dry-run"], in: fixture)
        XCTAssertEqual(docsOnly.status, 0, docsOnly.output)
        let docsDecision = try XCTUnwrap(try jsonLines(from: docsOnly.output).last)
        XCTAssertEqual(docsDecision["release"] as? Bool, false)
        XCTAssertEqual(docsDecision["reason"] as? String, "path-ineligible")

        try commit("app.mjs", contents: "console.log('prototype')\n", in: fixture)
        let prototypeOnly = try runScript(["--dry-run"], in: fixture)
        XCTAssertEqual(prototypeOnly.status, 0, prototypeOnly.output)
        let prototypeDecision = try XCTUnwrap(
            try jsonLines(from: prototypeOnly.output).last
        )
        XCTAssertEqual(prototypeDecision["release"] as? Bool, false)
        XCTAssertEqual(prototypeDecision["reason"] as? String, "path-ineligible")

        let forced = try runScript(["--force", "--dry-run"], in: fixture)
        XCTAssertEqual(forced.status, 0, forced.output)
        let forceDecision = try XCTUnwrap(try jsonLines(from: forced.output).last)
        XCTAssertEqual(forceDecision["release"] as? Bool, true)
        XCTAssertEqual(forceDecision["reason"] as? String, "force")

        try commit("app/Sources/StrataShowcase/Release.swift", contents: "release\n", in: fixture)
        let appChange = try runScript(["--dry-run"], in: fixture)
        XCTAssertEqual(appChange.status, 0, appChange.output)
        let appDecision = try XCTUnwrap(try jsonLines(from: appChange.output).last)
        XCTAssertEqual(appDecision["release"] as? Bool, true)
        XCTAssertEqual(appDecision["reason"] as? String, "eligible")

        try commit(
            ".github/repo-contract.json",
            contents: "{}\n",
            in: fixture
        )
        let dependencyChange = try runScript(["--dry-run"], in: fixture)
        XCTAssertEqual(dependencyChange.status, 0, dependencyChange.output)
        let dependencyDecision = try XCTUnwrap(
            try jsonLines(from: dependencyChange.output).last
        )
        XCTAssertEqual(dependencyDecision["release"] as? Bool, true)
        XCTAssertEqual(dependencyDecision["reason"] as? String, "eligible")
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func makeGateFixture() throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("testflight-gate-\(UUID().uuidString)")
        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: root.appendingPathComponent("scripts"),
            withIntermediateDirectories: true
        )
        try fileManager.copyItem(
            at: repositoryRoot.appendingPathComponent("scripts/testflight-gate.py"),
            to: root.appendingPathComponent("scripts/testflight-gate.py")
        )
        try "initial\n".write(
            to: root.appendingPathComponent("README.md"),
            atomically: true,
            encoding: .utf8
        )
        _ = try runGit(["init", "-q"], in: root)
        _ = try runGit(["config", "user.email", "test@example.com"], in: root)
        _ = try runGit(["config", "user.name", "Test User"], in: root)
        _ = try runGit(["add", "."], in: root)
        _ = try runGit(["commit", "-qm", "initial"], in: root)
        _ = try runGit(["tag", "testflight/last-released"], in: root)
        return root
    }

    private func commit(
        _ path: String,
        contents: String,
        in root: URL
    ) throws {
        let fileURL = root.appendingPathComponent(path)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        _ = try runGit(["add", path], in: root)
        _ = try runGit(["commit", "-qm", "change \(path)"], in: root)
    }

    private func runScript(
        _ arguments: [String],
        in root: URL
    ) throws -> ScriptResult {
        try run(["python3", "scripts/testflight-gate.py"] + arguments, in: root)
    }

    private func runGit(
        _ arguments: [String],
        in root: URL
    ) throws -> String {
        try run(["git"] + arguments, in: root).output
    }

    private func run(_ arguments: [String], in root: URL) throws -> ScriptResult {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = root
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

    private func jsonLines(from output: String) throws -> [[String: Any]] {
        try output.split(separator: "\n")
            .filter { $0.first == "{" }
            .map { line in
                try XCTUnwrap(
                    JSONSerialization.jsonObject(with: Data(line.utf8))
                        as? [String: Any]
                )
            }
    }
}

private struct ScriptResult {
    let status: Int32
    let output: String
}
