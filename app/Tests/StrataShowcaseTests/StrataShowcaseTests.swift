import DesignTokens
import Strata
import XCTest
@testable import StrataShowcase

final class StrataShowcaseTests: XCTestCase {
    func testEveryBrandThemeStateAndSectionResolves() throws {
        for brand in ShowcaseBrand.allCases {
            for appearance in Theme.allCases {
                for dataState in ShowcaseDataState.allCases {
                    for section in ShowcaseSection.allCases {
                        let configuration = try StrataShowcaseConfiguration(
                            brand: brand,
                            appearance: appearance,
                            surfaceStyle: .glass,
                            dataState: dataState,
                            section: section
                        )
                        XCTAssertEqual(configuration.brand, brand)
                        XCTAssertEqual(configuration.appearance, appearance)
                        XCTAssertEqual(configuration.dataState, dataState)
                        XCTAssertEqual(configuration.section, section)
                    }
                }
            }
        }
    }

    @MainActor
    func testInteractiveStateAndFeedbackBuilders() throws {
        var state = StrataShowcaseInteractionState()
        state.toggleSetCompletion("bench-1")
        XCTAssertTrue(state.completedSetIDs.contains("bench-1"))
        XCTAssertTrue(state.isSnackbarPresented)
        state.selectWorkoutMetric("left-right")
        state.selectMuscle("Back")
        state.selectLetter("B")
        state.presentRPEDialog()
        state.presentFinishConfirmation()
        XCTAssertEqual(state.selectedWorkoutMetric, "left-right")
        XCTAssertEqual(state.selectedMuscle, "Back")
        XCTAssertEqual(state.selectedLetter, "B")
        XCTAssertTrue(state.isDialogPresented)
        XCTAssertTrue(state.isFinishConfirmationPresented)

        let configuration = try StrataShowcaseConfiguration()
        let snackbar = try configuration.makeSnackbarItem(undo: {})
        XCTAssertEqual(snackbar.action?.label, "Undo")
        let timedSnackbar = try configuration.makeTimedSnackbarItem()
        XCTAssertNil(timedSnackbar.action)
        let dialog = try configuration.makeRPEDialogPresentation(onSelect: { _ in .dismiss })
        XCTAssertEqual(dialog.actions.count, 9)
        XCTAssertEqual(dialog.actions.first?.label, "RPE 6.0")
        XCTAssertEqual(dialog.actions.last?.label, "RPE 10.0")
    }

    func testTokenResolutionErrorIsUnchanged() {
        XCTAssertThrowsError(try StrataTheme(theme: .light, brand: "invalid-brand")) { error in
            XCTAssertEqual(error as? TokenError, .unknownBrand("invalid-brand"))
        }
    }

    func testConfigurationUsesProviderThemeForEachBrand() throws {
        for brand in ShowcaseBrand.allCases {
            let configuration = try StrataShowcaseConfiguration(brand: brand)
            XCTAssertEqual(configuration.theme.mode, .light)
        }
    }

    @MainActor
    func testLayeredShowcaseSupportsMobileAndDesktopRenderWidths() throws {
        let mobile = StrataShowcaseRootView(
            configuration: try StrataShowcaseConfiguration(section: .overview),
            rendersWithoutScrollView: true,
            renderWidth: 393
        )
        let desktop = StrataShowcaseRootView(
            configuration: try StrataShowcaseConfiguration(
                brand: .purple,
                appearance: .dark,
                surfaceStyle: .glass,
                section: .picker
            ),
            rendersWithoutScrollView: true,
            initialInspectorExpanded: true,
            renderWidth: 1200
        )

        XCTAssertEqual(mobile.renderWidth, 393)
        XCTAssertTrue(mobile.rendersWithoutScrollView)
        XCTAssertEqual(desktop.renderWidth, 1200)
        XCTAssertTrue(desktop.rendersWithoutScrollView)
    }

    @MainActor
    func testLayerNavigationPreservesAllShowcaseSections() throws {
        XCTAssertEqual(
            ShowcaseSection.allCases.map(\.rawValue),
            ["overview", "workout", "picker", "controls", "states"]
        )
        XCTAssertEqual(ShowcaseSection.allCases.map(\.title), [
            "Overview", "Workout", "Picker", "Controls", "States"
        ])

        let view = StrataShowcaseRootView(
            configuration: try StrataShowcaseConfiguration(section: .overview),
            rendersWithoutScrollView: true,
            renderWidth: 393
        )
        let tabs = view.compactLayerTabs
        XCTAssertEqual(tabs.count, 5)
        XCTAssertEqual(tabs.map(\.section), ShowcaseSection.allCases)
        XCTAssertEqual(Set(tabs.map(\.id)).count, tabs.count)
        for selectedSection in ShowcaseSection.allCases {
            XCTAssertEqual(tabs.filter { $0.section == selectedSection }.count, 1)
        }
    }

    func testLayeredTokenAndWorkoutValuesResolve() throws {
        XCTAssertNoThrow(try StrataTokenColor.resolve("status.strata.warning", theme: .light))

        let numberSlot = try StrataNumberSlotConfiguration(
            label: "Set 1",
            displayValue: "8",
            prefixBadge: "80 kg",
            unitLabel: "reps"
        )
        XCTAssertEqual(numberSlot.prefixBadge, "80 kg")
        XCTAssertEqual(numberSlot.displayValue, "8")
        XCTAssertEqual(numberSlot.unitLabel, "reps")
    }
}
