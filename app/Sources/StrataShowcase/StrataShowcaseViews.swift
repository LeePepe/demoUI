import DesignTokens
import Strata
import SwiftUI

public struct StrataShowcaseRootView: View {
    @State private var configuration: StrataShowcaseConfiguration
    @State private var interaction = StrataShowcaseInteractionState()
    @State private var searchText = ""
    @State private var notes = "Bench press"
    @State private var selectedExercise: String?
    @State private var selectedRadio = "moderate"
    @State private var isEnabled = true
    @State private var isChecked = true
    @State private var sliderValue = 6.0
    @State private var snackbarItem: StrataSnackbarItem?
    @State private var dialogPresentation: StrataDialogPresentation?
    @State private var configurationError: String?

    public init(configuration: StrataShowcaseConfiguration) {
        _configuration = State(initialValue: configuration)
    }

    public var body: some View {
        showcaseHost
            .background(configuration.theme.canvas.ignoresSafeArea())
            .environment(\.colorScheme, configuration.appearance == .light ? .light : .dark)
    }

    @ViewBuilder
    private var showcaseHost: some View {
        VStack(spacing: 0) {
            globalControls
            ScrollView {
                sectionContent
                    .padding(24)
                    .frame(maxWidth: 1400)
                    .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(configuration.theme.foreground)
        .overlay(alignment: .bottom) {
            if let configurationError {
                Text(configurationError)
                    .font(.footnote)
                    .foregroundStyle(configuration.theme.onCritical)
                    .padding(12)
                    .background(configuration.theme.critical, in: Capsule())
                    .padding()
            }
        }
    }

    private var globalControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strata Showcase")
                        .font(.largeTitle.weight(.bold))
                    Text("\(configuration.brand.title) / \(configuration.appearance.rawValue.capitalized) / \(configuration.surfaceStyle == .solid ? "Solid" : "Glass")")
                        .font(.subheadline)
                        .foregroundStyle(configuration.theme.secondaryForeground)
                }
                Spacer()
                Picker("Brand", selection: Binding(
                    get: { configuration.brand },
                    set: { updateConfiguration(brand: $0) }
                )) {
                    ForEach(ShowcaseBrand.allCases) { brand in
                        Text(brand.title).tag(brand)
                    }
                }
                .pickerStyle(.menu)
            }

            resolvedSegmentedBar(
                items: Theme.allCases.map {
                    StrataSegmentedItem(id: $0.rawValue, title: $0.rawValue.capitalized)
                },
                selection: Binding(
                    get: { configuration.appearance.rawValue },
                    set: { rawValue in
                        if let appearance = Theme(rawValue: rawValue) {
                            updateConfiguration(appearance: appearance)
                        }
                    }
                )
            )

            HStack(spacing: 8) {
                resolvedSegmentedBar(
                    items: [
                        StrataSegmentedItem(id: "solid", title: "Solid"),
                        StrataSegmentedItem(id: "glass", title: "Glass")
                    ],
                    selection: Binding(
                        get: { configuration.surfaceStyle == .solid ? "solid" : "glass" },
                        set: { updateConfiguration(surfaceStyle: $0 == "glass" ? .glass : .solid) }
                    )
                )
                resolvedSegmentedBar(
                    items: ShowcaseDataState.allCases.map {
                        StrataSegmentedItem(id: $0.rawValue, title: $0.rawValue.capitalized)
                    },
                    selection: Binding(
                        get: { configuration.dataState.rawValue },
                        set: { rawValue in
                            if let dataState = ShowcaseDataState(rawValue: rawValue) {
                                updateConfiguration(dataState: dataState)
                            }
                        }
                    )
                )
            }

            resolvedSegmentedBar(
                items: ShowcaseSection.allCases.map {
                    StrataSegmentedItem(id: $0.rawValue, title: $0.title)
                },
                selection: Binding(
                    get: { configuration.section.rawValue },
                    set: { rawValue in
                        if let section = ShowcaseSection(rawValue: rawValue) {
                            updateConfiguration(section: section)
                        }
                    }
                )
            )
        }
        .padding(20)
        .strataSurface(
            theme: configuration.theme,
            style: configuration.surfaceStyle,
            cornerRadius: 0,
            role: .region
        )
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch configuration.section {
        case .overview:
            overviewSection
        case .workout:
            workoutSection
        case .picker:
            pickerSection
        case .controls:
            controlsSection
        case .states:
            statesSection
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeading("Overview", subtitle: "Foundations, controls, patterns, and the active data state.")
            if configuration.dataState == .populated {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                    cardGallery
                    controlGallery
                    patternGallery
                }
            } else {
                statesSection
            }
        }
    }

    @ViewBuilder
    private var cardGallery: some View {
        StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Card and avatar")
                HStack {
                    StrataAvatar(
                        theme: configuration.theme,
                        size: .large,
                        accessibilityLabel: Text("Strata showcase avatar")
                    ) {
                        Text("S")
                    }
                    VStack(alignment: .leading) {
                        Text("Strata athlete")
                        Text("Foundations")
                            .font(.caption)
                            .foregroundStyle(configuration.theme.secondaryForeground)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var controlGallery: some View {
        StrataCard(
            theme: configuration.theme,
            surface: configuration.surfaceStyle,
            header: { Text("Controls") },
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    StrataSwitch(theme: configuration.theme, isOn: $isEnabled) {
                        Text("Enabled")
                    }
                    StrataCheckbox(theme: configuration.theme, isOn: $isChecked) {
                        Text("Completed")
                    }
                    StrataChip(theme: configuration.theme, tone: .accent) {
                        Text("Strength")
                    }
                }
            },
            supporting: { Text("Native bindings stay owned by the caller.") },
            actions: { EmptyView() }
        )
    }

    @ViewBuilder
    private var patternGallery: some View {
        StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
            VStack(alignment: .leading, spacing: 12) {
                Text("State \(configuration.dataState.rawValue.capitalized)")
                resolvedStateView(kind: .empty, title: "No recent sets", message: "Add a set to see it here.")
                resolvedProgressBar
            }
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading("Controls", subtitle: "Every Strata control receives the resolved theme explicitly.")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actions")
                        StrataButton(
                            theme: configuration.theme,
                            variant: .primary,
                            surface: configuration.surfaceStyle,
                            isLoading: configuration.dataState == .loading,
                            action: { interaction.presentRPEDialog() },
                            label: { Text("Open RPE dialog") },
                            loadingLabel: { Text("Opening") }
                        )
                        StrataButton(
                            theme: configuration.theme,
                            variant: .secondary,
                            surface: configuration.surfaceStyle,
                            isLoading: false,
                            action: { interaction.presentFinishConfirmation() },
                            label: { Text("Finish workout") },
                            loadingLabel: { Text("Finishing") }
                        )
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inputs")
                        StrataTextField(
                            theme: configuration.theme,
                            text: $notes,
                            prompt: Text("Exercise name"),
                            label: { Text("Search notes") }
                        )
                        resolvedSlider
                        resolvedRadioGroup
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Selection")
                        StrataSwitch(theme: configuration.theme, isOn: $isEnabled) {
                            Text("Notifications")
                        }
                        StrataCheckbox(theme: configuration.theme, isOn: $isChecked) {
                            Text("Use last weight")
                        }
                        StrataChip(
                            theme: configuration.theme,
                            tone: .critical,
                            removalAccessibilityLabel: Text("Remove filter"),
                            onRemove: { notes = "" }
                        ) {
                            Text("Needs review")
                        }
                    }
                }
            }
        }
    }

    private var workoutSection: some View {
        workoutHost
    }

    private var workoutContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading("Active Workout", subtitle: "Set completion, RPE, undo, and finish confirmation.")
            HStack {
                StrataSectionHeader(
                    theme: configuration.theme,
                    title: "Upper body strength",
                    subtitle: "Tuesday, 24 October",
                    badgeText: "3 exercises"
                ) {
                    workoutMenu
                }
                Spacer()
            }

            ForEach(["Bench press", "Cable row", "Shoulder press"], id: \.self) { exercise in
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(exercise)
                            .font(.headline)
                        HStack(spacing: 8) {
                            ForEach(1...3, id: \.self) { setNumber in
                                let id = "\(exercise)-\(setNumber)"
                                resolvedNumberSlot(
                                    id: id,
                                    isCompleted: interaction.completedSetIDs.contains(id),
                                    setNumber: setNumber
                                )
                            }
                        }
                    }
                }
            }

            resolvedSegmentedBar(
                items: [
                    StrataSegmentedItem(id: "overall", title: "Overall"),
                    StrataSegmentedItem(id: "left-right", title: "Left / Right")
                ],
                selection: Binding(
                    get: { interaction.selectedWorkoutMetric },
                    set: { interaction.selectWorkoutMetric($0) }
                )
            )

            HStack(spacing: 12) {
                StrataButton(
                    theme: configuration.theme,
                    variant: .secondary,
                    surface: configuration.surfaceStyle,
                    isLoading: false,
                    action: { interaction.presentRPEDialog() },
                    label: { Text("Rate RPE") },
                    loadingLabel: { Text("Opening") }
                )
                StrataButton(
                    theme: configuration.theme,
                    variant: .primary,
                    surface: configuration.surfaceStyle,
                    isLoading: false,
                    action: { interaction.presentFinishConfirmation() },
                    label: { Text("Finish workout") },
                    loadingLabel: { Text("Finishing") }
                )
            }
        }
    }

    private var pickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading("Exercise Picker", subtitle: "Muscle rail, searchable exercise cards, index rail, and docked actions.")
            HStack(alignment: .top, spacing: 16) {
                resolvedSegmentedBar(
                    items: ["Chest", "Back", "Legs", "Shoulders"].map {
                        StrataSegmentedItem(id: $0, title: $0, badgeCount: $0 == "Chest" ? 8 : 4)
                    },
                    selection: Binding(
                        get: { interaction.selectedMuscle },
                        set: { interaction.selectMuscle($0) }
                    ),
                    axis: .vertical
                )
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(interaction.selectedMuscle) exercises")
                        .font(.headline)
                    ForEach(["Barbell bench press", "Incline dumbbell press", "Cable fly"], id: \.self) { exercise in
                        StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                            HStack {
                                StrataAvatar(
                                    theme: configuration.theme,
                                    size: .medium,
                                    accessibilityLabel: Text(exercise)
                                ) {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                }
                                VStack(alignment: .leading) {
                                    Text(exercise)
                                    Text("Chest · \(configuration.dataState.rawValue)")
                                        .font(.caption)
                                        .foregroundStyle(configuration.theme.secondaryForeground)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(configuration.theme.secondaryForeground)
                            }
                        }
                        .onTapGesture { selectedExercise = exercise }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                StrataIndexRail(
                    theme: configuration.theme,
                    items: ["A", "B", "C", "D", "E", "F"].map {
                        StrataIndexRailItem(id: $0, shortLabel: $0, fullTitle: "Exercises beginning with \($0)")
                    },
                    activeID: interaction.selectedLetter,
                    showsHUD: true,
                    onSelect: { interaction.selectLetter($0) }
                )
            }
            resolvedDockedBar
        }
    }

    private var statesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading("States", subtitle: "Empty, loading, and error states remain explicit and actionable.")
            HStack(alignment: .top, spacing: 12) {
                resolvedStateView(kind: .empty, title: "Nothing here", message: "Create a workout to populate this view.", actionTitle: "Create workout")
                resolvedStateView(kind: .loading, title: "Loading workout", message: "Resolving the latest session.")
                resolvedStateView(kind: .error, title: "Could not load", message: "Try again when the connection is restored.", actionTitle: "Retry")
            }
            StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Feedback playground")
                    StrataButton(
                        theme: configuration.theme,
                        variant: .secondary,
                        surface: configuration.surfaceStyle,
                        isLoading: false,
                        action: { interaction.isSnackbarPresented = true },
                        label: { Text("Show snackbar") },
                        loadingLabel: { Text("Showing") }
                    )
                }
            }
        }
    }

    private var workoutHost: some View {
        AnyView(
            configuredFeedbackHost(content: workoutContent)
        )
    }

    private func configuredFeedbackHost<Content: View>(content: Content) -> some View {
        do {
            let snackbar = try StrataSnackbar.Configuration(
                theme: configuration.theme,
                item: $snackbarItem,
                content: { content },
                bottomBar: { EmptyView() }
            )
            let snackbarView = StrataSnackbar(configuration: snackbar)
            let dialog = try StrataDialog.Configuration(
                theme: configuration.theme,
                presentation: $dialogPresentation,
                base: { snackbarView },
                content: { presentation in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a score")
                            .font(.headline)
                        ForEach(presentation.actions) { action in
                            Button(action.label) {
                                let outcome = action.perform()
                                if outcome == .dismiss {
                                    dialogPresentation = nil
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            )
            let dialogView = StrataDialog(configuration: dialog)
            let alert = try StrataAlertDialog.Configuration(
                theme: configuration.theme,
                isPresented: Binding(
                    get: { interaction.isFinishConfirmationPresented },
                    set: { interaction.isFinishConfirmationPresented = $0 }
                ),
                title: "Finish workout?",
                message: "This marks the active session complete.",
                confirmLabel: "Finish",
                cancelLabel: "Keep going",
                isDestructive: false,
                confirm: { interaction.isFinishConfirmationPresented = false },
                base: { dialogView }
            )
            return AnyView(StrataAlertDialog(configuration: alert))
        } catch {
            return AnyView(failureView(error))
        }
    }

    private var workoutMenu: some View {
        do {
            return AnyView(try StrataMenu(
                theme: configuration.theme,
                label: "More workout actions",
                actions: [
                    StrataMenuAction(
                        id: "duplicate",
                        title: "Duplicate set",
                        systemImage: "plus",
                        handler: {}
                    ),
                    StrataMenuAction(
                        id: "remove",
                        title: "Remove workout",
                        systemImage: "trash",
                        role: .destructive,
                        handler: {}
                    )
                ]
            ))
        } catch {
            return AnyView(failureView(error))
        }
    }

    private func resolvedNumberSlot(id: String, isCompleted: Bool, setNumber: Int) -> some View {
        do {
            let numberSlot = try StrataNumberSlotConfiguration(
                label: "Set \(setNumber)",
                displayValue: "\(setNumber * 8)",
                unitLabel: "reps",
                isActive: !isCompleted,
                isCompleted: isCompleted
            )
            return AnyView(StrataNumberSlot(
                theme: configuration.theme,
                configuration: numberSlot,
                action: { interaction.toggleSetCompletion(id) }
            ))
        } catch {
            return AnyView(failureView(error))
        }
    }

    private var resolvedDockedBar: some View {
        do {
            let searchConfiguration = try StrataSearchFieldConfiguration(
                label: "Search exercises",
                placeholder: "Search by name",
                clearLabel: "Clear search",
                resultSummary: searchText.isEmpty ? "All exercises" : "Matching exercises"
            )
            return AnyView(StrataDockedBar(theme: configuration.theme, style: configuration.surfaceStyle) {
                HStack(spacing: 12) {
                    StrataSearchField(
                        theme: configuration.theme,
                        text: $searchText,
                        configuration: searchConfiguration
                    )
                    StrataButton(
                        theme: configuration.theme,
                        variant: .primary,
                        surface: .solid,
                        isLoading: false,
                        action: { selectedExercise = "New exercise" },
                        label: { Text("Add") },
                        loadingLabel: { Text("Adding") }
                    )
                }
            })
        } catch {
            return AnyView(failureView(error))
        }
    }

    private var resolvedSlider: some View {
        do {
            return AnyView(try StrataSlider(
                theme: configuration.theme,
                value: $sliderValue,
                in: 1...10,
                step: 0.5,
                onEditingChanged: { _ in },
                label: { Text("RPE") },
                minimumValueLabel: { Text("1") },
                maximumValueLabel: { Text("10") }
            ))
        } catch {
            return AnyView(failureView(error))
        }
    }

    private var resolvedRadioGroup: some View {
        StrataRadioGroup(
            theme: configuration.theme,
            selection: $selectedRadio,
            label: { Text("Training focus") },
            options: {
                Text("Easy").tag("easy")
                Text("Moderate").tag("moderate")
                Text("Hard").tag("hard")
            }
        )
    }

    private var resolvedProgressBar: some View {
        StrataProgressBar(
            theme: configuration.theme,
            value: configuration.dataState == .loading ? nil : 68,
            total: 100,
            label: { Text("Weekly volume") },
            currentValueLabel: { Text(configuration.dataState == .loading ? "Waiting" : "68%") }
        )
    }

    private func resolvedStateView(
        kind: StrataStateView.Kind,
        title: String,
        message: String,
        actionTitle: String? = nil
    ) -> some View {
        do {
            return AnyView(try StrataStateView(
                theme: configuration.theme,
                kind: kind,
                title: title,
                message: message,
                actionTitle: actionTitle,
                action: { selectedExercise = "Created" }
            ))
        } catch {
            return AnyView(failureView(error))
        }
    }

    private func resolvedSegmentedBar(
        items: [StrataSegmentedItem],
        selection: Binding<String>,
        axis: StrataSegmentedBar.Axis = .horizontal
    ) -> some View {
        AnyView(StrataSegmentedBar(
            theme: configuration.theme,
            items: items,
            selection: selection,
            axis: axis,
            metrics: configuration.metrics
        ))
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        StrataSectionHeader(
            theme: configuration.theme,
            title: title,
            subtitle: subtitle
        ) {
            StrataChip(theme: configuration.theme, tone: .neutral) {
                Text(configuration.dataState.rawValue.capitalized)
            }
        }
    }

    private func failureView(_ error: Error) -> some View {
        Text(String(describing: error))
            .font(.footnote)
            .foregroundStyle(configuration.theme.critical)
            .padding(12)
            .strataSurface(theme: configuration.theme, style: .solid, cornerRadius: 12, role: .card)
    }

    private func updateConfiguration(
        brand: ShowcaseBrand? = nil,
        appearance: Theme? = nil,
        surfaceStyle: StrataSurfaceStyle? = nil,
        dataState: ShowcaseDataState? = nil,
        section: ShowcaseSection? = nil
    ) {
        do {
            configuration = try configuration.replacing(
                brand: brand,
                appearance: appearance,
                surfaceStyle: surfaceStyle,
                dataState: dataState,
                section: section
            )
            configurationError = nil
        } catch {
            configurationError = String(describing: error)
        }
    }
}
