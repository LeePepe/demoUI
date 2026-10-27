import DesignTokens
import Strata

public enum ShowcaseBrand: String, CaseIterable, Identifiable, Sendable {
    case blue = "strata-blue"
    case green = "strata-green"
    case pink = "strata-pink"
    case yellow = "strata-yellow"
    case purple = "strata-purple"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .blue: "Blue"
        case .green: "Green"
        case .pink: "Pink"
        case .yellow: "Yellow"
        case .purple: "Purple"
        }
    }
}

public enum ShowcaseSection: String, CaseIterable, Identifiable, Sendable {
    case overview
    case workout
    case picker
    case controls
    case states

    public var id: String { rawValue }

    public var title: String {
        rawValue.capitalized
    }
}

public enum ShowcaseDataState: String, CaseIterable, Identifiable, Sendable {
    case populated
    case empty
    case loading
    case error

    public var id: String { rawValue }
}

public struct StrataShowcaseConfiguration {
    public let brand: ShowcaseBrand
    public let appearance: Theme
    public let surfaceStyle: StrataSurfaceStyle
    public let dataState: ShowcaseDataState
    public let section: ShowcaseSection
    public let theme: StrataTheme
    public let metrics: StrataComponentMetrics

    public init(
        brand: ShowcaseBrand = .blue,
        appearance: Theme = .light,
        surfaceStyle: StrataSurfaceStyle = .solid,
        dataState: ShowcaseDataState = .populated,
        section: ShowcaseSection = .overview
    ) throws {
        self.brand = brand
        self.appearance = appearance
        self.surfaceStyle = surfaceStyle
        self.dataState = dataState
        self.section = section
        theme = try StrataTheme(theme: appearance, brand: brand.rawValue)
        metrics = try StrataComponentMetrics()
    }

    public func replacing(
        brand: ShowcaseBrand? = nil,
        appearance: Theme? = nil,
        surfaceStyle: StrataSurfaceStyle? = nil,
        dataState: ShowcaseDataState? = nil,
        section: ShowcaseSection? = nil
    ) throws -> StrataShowcaseConfiguration {
        try StrataShowcaseConfiguration(
            brand: brand ?? self.brand,
            appearance: appearance ?? self.appearance,
            surfaceStyle: surfaceStyle ?? self.surfaceStyle,
            dataState: dataState ?? self.dataState,
            section: section ?? self.section
        )
    }

    @MainActor
    public func makeSnackbarItem(
        undo: @escaping @Sendable @MainActor () -> Void
    ) throws -> StrataSnackbarItem {
        let action = try StrataSnackbarAction(label: "Undo", perform: undo)
        return try StrataSnackbarItem(
            message: "Set marked complete",
            closeLabel: "Dismiss",
            action: action
        )
    }

    @MainActor
    public func makeTimedSnackbarItem() throws -> StrataSnackbarItem {
        try StrataSnackbarItem(
            message: "This snackbar dismisses in 5 seconds",
            closeLabel: "Dismiss"
        )
    }

    @MainActor
    public func makeRPEDialogPresentation(
        onSelect: @escaping @Sendable @MainActor (Double) -> StrataDialogActionOutcome
    ) throws -> StrataDialogPresentation {
        let actions = try stride(from: 6.0, through: 10.0, by: 0.5).map { rpe in
            try StrataDialogAction(
                id: "rpe-\(Int(rpe * 10))",
                label: "RPE \(rpe.formatted(.number.precision(.fractionLength(1))))",
                role: .secondary,
                perform: { onSelect(rpe) }
            )
        }
        return try StrataDialogPresentation(
            title: "Rate perceived exertion",
            closeLabel: "Close",
            actions: actions
        )
    }
}

public struct StrataShowcaseInteractionState: Equatable, Sendable {
    public var completedSetIDs: Set<String> = []
    public var selectedWorkoutMetric = "overall"
    public var selectedMuscle = "Chest"
    public var selectedLetter = "A"
    public var isSnackbarPresented = false
    public var isDialogPresented = false
    public var isFinishConfirmationPresented = false

    public init() {}

    public mutating func toggleSetCompletion(_ id: String) {
        if completedSetIDs.insert(id).inserted {
            isSnackbarPresented = true
        } else {
            completedSetIDs.remove(id)
        }
    }

    public mutating func selectWorkoutMetric(_ id: String) {
        selectedWorkoutMetric = id
    }

    public mutating func selectMuscle(_ id: String) {
        selectedMuscle = id
    }

    public mutating func selectLetter(_ id: String) {
        selectedLetter = id
    }

    public mutating func presentRPEDialog() {
        isDialogPresented = true
    }

    public mutating func presentFinishConfirmation() {
        isFinishConfirmationPresented = true
    }
}
