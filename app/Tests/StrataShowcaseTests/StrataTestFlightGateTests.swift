import XCTest

final class StrataTestFlightGateTests: XCTestCase {
    func testTestFlightReleaseContractIsWired() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let exampleSigning = try String(
            contentsOf: repositoryRoot.appendingPathComponent("config/Signing.example.xcconfig"),
            encoding: .utf8
        )
        XCTAssertTrue(exampleSigning.contains("DEMOUI_BUNDLE_ID = com.example.demoui"))
        XCTAssertTrue(exampleSigning.contains("DEMOUI_TEAM_ID = ZZZZZZZZZZ"))

        let project = try String(
            contentsOf: repositoryRoot.appendingPathComponent("app/project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("Signing.local.xcconfig"))
        XCTAssertTrue(project.contains("PRODUCT_BUNDLE_IDENTIFIER: \"$(DEMOUI_BUNDLE_ID)\""))
        XCTAssertTrue(project.contains("DEVELOPMENT_TEAM: \"$(DEMOUI_TEAM_ID)\""))

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
    }
}
