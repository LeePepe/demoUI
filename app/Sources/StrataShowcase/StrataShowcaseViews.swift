import DesignTokens
import Strata
import SwiftUI

private struct ShowcaseListEntry: Identifiable {
    let id: String
    let title: String
    let detail: String
}

private struct ShowcaseLayerTab: Identifiable {
    let id: String
    let title: String
    let section: ShowcaseSection
}

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
    @State private var isInspectorExpanded: Bool
    public let rendersWithoutScrollView: Bool
    public let renderWidth: CGFloat?

    public init(
        configuration: StrataShowcaseConfiguration,
        rendersWithoutScrollView: Bool = false,
        initialInspectorExpanded: Bool = false,
        renderWidth: CGFloat? = nil
    ) {
        _configuration = State(initialValue: configuration)
        _isInspectorExpanded = State(initialValue: initialInspectorExpanded)
        self.rendersWithoutScrollView = rendersWithoutScrollView
        self.renderWidth = renderWidth
    }

    public var body: some View {
        showcaseHost
            .background(configuration.theme.canvas.ignoresSafeArea())
            .environment(\.colorScheme, configuration.appearance == .light ? .light : .dark)
    }

    @ViewBuilder
    private var showcaseHost: some View {
        configuredFeedbackHost(content:
            VStack(spacing: 0) {
                globalHeader
                layerTabBar
                if rendersWithoutScrollView {
                    sectionContent
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .frame(width: max((renderWidth ?? 393) - 32, 0), alignment: .top)
                } else {
                    ScrollView {
                        sectionContent
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .frame(maxWidth: 1400)
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                }

            }
            .foregroundStyle(configuration.theme.foreground)
            .frame(
                minHeight: rendersWithoutScrollView ? 852 : nil,
                alignment: .top
            )
            .frame(width: renderWidth, alignment: .top)
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
        )
    }

    private var globalHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Strata")
                        .font(.title2.weight(.bold))
                        .lineLimit(1)
                }
                .frame(minWidth: 86, alignment: .leading)
                .layoutPriority(1)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    ForEach(ShowcaseBrand.allCases) { brand in
                        brandSwatch(brand)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)

                Button {
                    isInspectorExpanded.toggle()
                } label: {
                    Label("Theme", systemImage: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 36)
                }
                .buttonStyle(.plain)
                .foregroundStyle(configuration.theme.foreground)
                .background(configuration.theme.surface(.inset), in: Capsule())
                .accessibilityValue(isInspectorExpanded ? "Expanded" : "Collapsed")
            }

            Text(configurationSummary)
                .font(.caption.weight(.medium))
                .foregroundStyle(configuration.theme.secondaryForeground)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isInspectorExpanded {
                inspector
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .strataSurface(
            theme: configuration.theme,
            style: configuration.surfaceStyle,
            cornerRadius: 0,
            role: .region
        )
    }

    private var configurationSummary: String {
        "\(configuration.brand.title) · \(configuration.appearance.rawValue.capitalized) · \(configuration.surfaceStyle == .solid ? "Solid" : "Glass") · \(configuration.dataState.rawValue.capitalized)"
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                inspectorPillGroup(
                    label: "Appearance",
                    items: Theme.allCases.map { ($0.rawValue, $0.rawValue.capitalized) },
                    selection: configuration.appearance.rawValue
                ) { value in
                    if let appearance = Theme(rawValue: value) {
                        updateConfiguration(appearance: appearance)
                    }
                }
                inspectorPillGroup(
                    label: "Surface",
                    items: [("solid", "Solid"), ("glass", "Glass")],
                    selection: configuration.surfaceStyle == .solid ? "solid" : "glass"
                ) { value in
                    updateConfiguration(surfaceStyle: value == "glass" ? .glass : .solid)
                }
            }
            inspectorPillGroup(
                label: "Data state",
                items: ShowcaseDataState.allCases.map { ($0.rawValue, $0.rawValue.capitalized) },
                selection: configuration.dataState.rawValue,
                distributesItems: true
            ) { value in
                if let dataState = ShowcaseDataState(rawValue: value) {
                    updateConfiguration(dataState: dataState)
                }
            }
        }
    }

    private func inspectorPillGroup(
        label: String,
        items: [(String, String)],
        selection: String,
        distributesItems: Bool = false,
        action: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(configuration.theme.secondaryForeground)
                .lineLimit(1)
            HStack(spacing: 4) {
                ForEach(items, id: \.0) { item in
                    Button {
                        action(item.0)
                    } label: {
                        Text(item.1)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .fixedSize(horizontal: !distributesItems, vertical: false)
                            .frame(maxWidth: distributesItems ? .infinity : nil)
                            .frame(minHeight: 34)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(item.0 == selection ? configuration.theme.onAccent : configuration.theme.foreground)
                    .background(
                        item.0 == selection ? configuration.theme.accent : configuration.theme.surface(.card),
                        in: Capsule()
                    )
                    .accessibilityAddTraits(item.0 == selection ? .isSelected : [])
                }
            }
            .padding(4)
            .background(configuration.theme.surface(.inset), in: Capsule())
        }
        .frame(maxWidth: distributesItems ? .infinity : nil, alignment: .leading)
    }

    private func brandSwatch(_ brand: ShowcaseBrand) -> some View {
        do {
            let brandTheme = try StrataTheme(theme: configuration.appearance, brand: brand.rawValue)
            return AnyView(
                Button {
                    updateConfiguration(brand: brand)
                } label: {
                    ZStack {
                        Circle()
                            .fill(brandTheme.accent)
                            .frame(width: 26, height: 26)
                        if configuration.brand == brand {
                            Circle()
                                .stroke(configuration.theme.foreground, lineWidth: 2)
                                .frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(brandTheme.onAccent)
                        }
                    }
                    .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(brand.title)
                .accessibilityAddTraits(configuration.brand == brand ? .isSelected : [])
            )
        } catch {
            return AnyView(failureView(error))
        }
    }

    @ViewBuilder
    private var layerTabBar: some View {
        Group {
            if rendersWithoutScrollView, (renderWidth ?? .infinity) <= 600 {
                compactLayerTabItems
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
            } else if rendersWithoutScrollView {
                layerTabItems
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 54)
                    .clipped()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    layerTabItems
                }
                .frame(height: 54)
            }
        }
        .frame(width: renderWidth, alignment: .leading)
        .clipped()
        .background(configuration.theme.canvas)
    }

    private var compactLayerTabItems: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach([
                ShowcaseLayerTab(id: "all-layers", title: "All Layers", section: .overview),
                ShowcaseLayerTab(id: "tokens", title: "L1 · Tokens", section: .overview),
                ShowcaseLayerTab(id: "controls", title: "L2 · Controls", section: .controls),
                ShowcaseLayerTab(id: "feedback", title: "L3 · Feedback", section: .states),
                ShowcaseLayerTab(id: "workout", title: "L4 · Workout", section: .workout),
                ShowcaseLayerTab(id: "picker", title: "L4 · Picker", section: .picker)
            ]) { tab in
                layerTabButton(title: tab.title, section: tab.section)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var layerTabItems: some View {
        HStack(spacing: 8) {
            ForEach(ShowcaseSection.allCases) { section in
                layerTabButton(title: layerTabTitle(section), section: section)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func layerTabButton(title: String, section: ShowcaseSection) -> some View {
        Button {
            updateConfiguration(section: section)
        } label: {
            Text(title)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: !((renderWidth ?? .infinity) <= 600), vertical: false)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .frame(minHeight: 38)
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            configuration.section == section
                ? configuration.theme.onAccent
                : configuration.theme.foreground
        )
        .background(
            configuration.section == section
                ? configuration.theme.accent
                : configuration.theme.surface(.card),
            in: Capsule()
        )
        .accessibilityAddTraits(configuration.section == section ? .isSelected : [])
    }

    private func layerTabTitle(_ section: ShowcaseSection) -> String {
        switch section {
        case .overview: "All Layers"
        case .workout: "L4 · Workout"
        case .picker: "L4 · Picker"
        case .controls: "L2 · Controls"
        case .states: "L3 · Feedback"
        }
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
        VStack(alignment: .leading, spacing: 24) {
            layerHeader(
                number: "SHOWCASE",
                title: "Strata design system",
                subtitle: "A layered component language for VitalStride product surfaces."
            )
            if configuration.dataState == .populated {
                foundationsLayer
                controlsLayer
                feedbackLayer
                compositionsLayer
            } else {
                activeDataStateView
            }
        }
    }

    private var foundationsLayer: some View {
        layerSection(
            number: "LAYER 01",
            title: "Foundations & Surfaces",
            subtitle: "Tokens, semantic surfaces, identity primitives"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                tokenSwatches
                if rendersWithoutScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        foundationMaterialCard
                        foundationIdentityCard
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                        foundationMaterialCard
                        foundationIdentityCard
                    }
                }
            }
        }
    }

    private var foundationMaterialCard: some View {
        StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Material comparison")
                    .font(.headline)
                HStack(spacing: 10) {
                    materialTile(title: "Solid", style: .solid)
                    materialTile(title: "Glass", style: .glass)
                }
            }
        }
    }

    private var foundationIdentityCard: some View {
        StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Identity scale")
                    .font(.headline)
                HStack(spacing: 14) {
                    avatar("S", size: .small, label: "Small avatar")
                    avatar("S", size: .medium, label: "Medium avatar")
                    avatar("S", size: .large, label: "Large avatar")
                }
                resolvedProgressBar
            }
        }
    }

    private var tokenSwatches: some View {
        do {
            let warning = try StrataTokenColor.resolve(
                "status.strata.warning",
                theme: configuration.appearance
            )
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Semantic token map")
                        .font(.headline)
                    tokenSwatchItems(warningColor: warning)
                }
            )
        } catch {
            return AnyView(failureView(error))
        }
    }

    private func tokenSwatchItems(warningColor: Color) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 76), spacing: 8)],
            spacing: 8
        ) {
            tokenSwatch("Canvas", color: configuration.theme.canvas)
            tokenSwatch("Surface", color: configuration.theme.surface)
            tokenSwatch("Elevated", color: configuration.theme.surface(.card))
            tokenSwatch("Accent", color: configuration.theme.accent)
            tokenSwatch("Success", color: configuration.theme.success)
            tokenSwatch("Warning", color: warningColor)
            tokenSwatch("Critical", color: configuration.theme.critical)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tokenSwatch(_ title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(configuration.theme.foreground.opacity(0.16), lineWidth: 1)
                }
            Text(title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) token")
    }

    private func materialTile(title: String, style: StrataSurfaceStyle) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            ZStack {
                Image(systemName: style == .solid ? "square.fill" : "square.stack.3d.up")
                    .font(.title2)
                    .foregroundStyle(configuration.theme.accent)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .strataSurface(theme: configuration.theme, style: style, cornerRadius: 14, role: .card)
        }
    }

    private func avatar(_ text: String, size: StrataAvatarSize, label: String) -> some View {
        StrataAvatar(theme: configuration.theme, size: size, accessibilityLabel: Text(label)) {
            Text(text)
        }
    }

    private var controlsLayer: some View {
        layerSection(
            number: "LAYER 02",
            title: "Form Controls & Inputs",
            subtitle: "Actions, selection, text entry, and adjustable values"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actions & filters")
                            .font(.headline)
                        HStack(spacing: 8) {
                            showcaseButton("Primary", variant: .primary) { presentRPEDialog() }
                            showcaseButton("Secondary", variant: .secondary) {}
                            showcaseButton("Destructive", variant: .secondary) { notes = "" }
                        }
                        HStack(spacing: 8) {
                            StrataChip(theme: configuration.theme, tone: .accent) { Text("Strength").lineLimit(1) }
                            StrataChip(theme: configuration.theme, tone: .neutral) { Text("3 sets").lineLimit(1) }
                            StrataChip(theme: configuration.theme, tone: .critical) { Text("Needs review").lineLimit(1) }
                        }
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Text and numeric input")
                            .font(.headline)
                        resolvedSearchField
                        resolvedNotesField
                        resolvedSlider
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selection controls")
                            .font(.headline)
                        selectionControls
                    }
                }
            }
        }
    }

    private func showcaseButton(
        _ title: String,
        variant: StrataButtonVariant,
        action: @escaping () -> Void
    ) -> some View {
        StrataButton(
            theme: configuration.theme,
            variant: variant,
            surface: configuration.surfaceStyle,
            isLoading: false,
            action: action,
            label: { Text(title).lineLimit(1).minimumScaleFactor(0.8) },
            loadingLabel: { Text("Working").lineLimit(1) }
        )
    }

    private var feedbackLayer: some View {
        layerSection(
            number: "LAYER 03",
            title: "Navigation, Modals & Feedback",
            subtitle: "Headers, menus, transient feedback, dialogs, and lists"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 12) {
                        StrataSectionHeader(
                            theme: configuration.theme,
                            title: "Recent training",
                            subtitle: "Choose an exercise to continue",
                            badgeText: "2 items"
                        ) {
                            workoutMenu
                        }
                        resolvedList
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Feedback playground")
                            .font(.headline)
                        HStack(spacing: 8) {
                            showcaseButton("Undo snackbar", variant: .secondary) { presentUndoSnackbar() }
                            showcaseButton("5s timer", variant: .secondary) { presentTimedSnackbar() }
                        }
                        HStack(spacing: 8) {
                            showcaseButton("RPE dialog", variant: .primary) { presentRPEDialog() }
                            showcaseButton("Finish confirmation", variant: .secondary) {
                                interaction.presentFinishConfirmation()
                            }
                        }
                    }
                }
            }
        }
    }

    private var compositionsLayer: some View {
        layerSection(
            number: "LAYER 04",
            title: "VitalStride Product Compositions",
            subtitle: "Focused previews of the workout and exercise picker flows"
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Active workout set table")
                                .font(.headline)
                            Spacer()
                            Text("L4")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(configuration.theme.accent)
                        }
                        HStack(spacing: 8) {
                            resolvedNumberSlot(id: "overview-bench", isCompleted: false, setNumber: 1)
                            resolvedNumberSlot(id: "overview-reps", isCompleted: true, setNumber: 2)
                        }
                        showcaseButton("Open Workout", variant: .primary) {
                            updateConfiguration(section: .workout)
                        }
                    }
                }
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Exercise picker")
                                .font(.headline)
                            Spacer()
                            Text("L4")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(configuration.theme.accent)
                        }
                        HStack(spacing: 8) {
                            VStack(spacing: 4) {
                                ForEach(["A", "B", "C"], id: \.self) { letter in
                                    Text(letter)
                                        .font(.caption.weight(.bold))
                                        .frame(width: 28, height: 26)
                                        .background(
                                            letter == "A" ? configuration.theme.accentSubtle : configuration.theme.surface(.inset),
                                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        )
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bench press")
                                Text("Cable fly")
                            }
                            .font(.subheadline)
                            .foregroundStyle(configuration.theme.secondaryForeground)
                            Spacer()
                        }
                        showcaseButton("Open Picker", variant: .secondary) {
                            updateConfiguration(section: .picker)
                        }
                    }
                }
            }
        }
    }

    private func layerSection<Content: View>(
        number: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            layerHeader(number: number, title: title, subtitle: subtitle)
            content()
        }
        .padding(14)
        .strataSurface(
            theme: configuration.theme,
            style: configuration.surfaceStyle,
            cornerRadius: 20,
            role: .region
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func layerHeader(number: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(number)
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(configuration.theme.accent)
                .lineLimit(1)
            Text(title)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(configuration.theme.secondaryForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    @ViewBuilder
    private var workoutSection: some View {
        if configuration.dataState == .populated {
            workoutContent
        } else {
            VStack(alignment: .leading, spacing: 16) {
                layerHeader(
                    number: "LAYER 04",
                    title: "VitalStride Active Workout",
                    subtitle: "A mobile-ready composition for a live training session."
                )
                activeDataStateView
            }
        }
    }

    private var workoutContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            layerHeader(
                number: "LAYER 04 · WORKOUT",
                title: "Upper Body Strength",
                subtitle: "Tuesday · 3 exercises"
            )
            StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                VStack(alignment: .leading, spacing: 12) {
                    StrataSectionHeader(
                        theme: configuration.theme,
                        title: "Upper Body Strength",
                        subtitle: "Tuesday · 3 exercises",
                        badgeText: "9 sets"
                    ) {
                        workoutMenu
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
                }
            }

            ForEach(["Bench press", "Cable row", "Shoulder press"], id: \.self) { exercise in
                StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exercise)
                            .font(.headline)
                            .lineLimit(1)
                        ForEach(1...3, id: \.self) { setNumber in
                            let id = "\(exercise)-\(setNumber)"
                            HStack(spacing: 10) {
                                Text("Set \(setNumber)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(configuration.theme.secondaryForeground)
                                    .lineLimit(1)
                                    .frame(width: 48, alignment: .leading)
                                resolvedNumberSlot(
                                    id: id,
                                    isCompleted: interaction.completedSetIDs.contains(id),
                                    setNumber: setNumber
                                )
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                showcaseButton("Rate RPE", variant: .secondary) { presentRPEDialog() }
                showcaseButton("Finish workout", variant: .primary) {
                    interaction.presentFinishConfirmation()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var pickerSection: some View {
        if configuration.dataState == .populated {
            pickerContent
        } else {
            VStack(alignment: .leading, spacing: 16) {
                layerHeader(
                    number: "LAYER 04",
                    title: "VitalStride Exercise Picker",
                    subtitle: "Find the next movement without losing context."
                )
                activeDataStateView
            }
        }
    }

    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            layerHeader(
                number: "LAYER 04 · PICKER",
                title: "VitalStride Exercise Picker",
                subtitle: "Muscle rail, focused exercise cards, index rail, and docked actions."
            )
            HStack(alignment: .top, spacing: 8) {
                resolvedSegmentedBar(
                    items: [
                        StrataSegmentedItem(id: "All 7", title: "All 7"),
                        StrataSegmentedItem(id: "Chest", title: "Chest 3"),
                        StrataSegmentedItem(id: "Back", title: "Back 2"),
                        StrataSegmentedItem(id: "Legs", title: "Legs 2")
                    ],
                    selection: Binding(
                        get: { interaction.selectedMuscle },
                        set: { interaction.selectMuscle($0) }
                    ),
                    axis: .vertical
                )
                .frame(width: 76, alignment: .top)

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(interaction.selectedMuscle) exercises")
                        .font(.headline)
                        .lineLimit(1)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 10)], spacing: 10) {
                        ForEach(["Barbell bench press", "Incline dumbbell press", "Cable fly"], id: \.self) { exercise in
                            StrataCard(theme: configuration.theme, surface: configuration.surfaceStyle) {
                                HStack(spacing: 10) {
                                    StrataAvatar(
                                        theme: configuration.theme,
                                        size: .medium,
                                        accessibilityLabel: Text(exercise)
                                    ) {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(exercise)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Text("Chest · 3 sets")
                                            .font(.caption)
                                            .foregroundStyle(configuration.theme.secondaryForeground)
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(configuration.theme.secondaryForeground)
                                }
                            }
                            .onTapGesture { selectedExercise = exercise }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                StrataIndexRail(
                    theme: configuration.theme,
                    items: ["A", "B", "C", "L", "R", "S"].map {
                        StrataIndexRailItem(id: $0, shortLabel: $0, fullTitle: "Exercises beginning with \($0)")
                    },
                    activeID: interaction.selectedLetter,
                    showsHUD: !rendersWithoutScrollView,
                    onSelect: { interaction.selectLetter($0) }
                )
                .frame(width: 28)
            }
            resolvedDockedBar
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            layerHeader(
                number: "LAYER 02",
                title: "Controls & Inputs",
                subtitle: "The complete interaction vocabulary, isolated for review."
            )
            controlsLayer
        }
    }

    private var statesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            layerHeader(
                number: "LAYER 03",
                title: "Feedback & States",
                subtitle: "Empty, loading, and error states remain explicit and actionable."
            )
            if configuration.dataState != .populated {
                activeDataStateView
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                resolvedStateView(kind: .empty, title: "Nothing here", message: "Create a workout to populate this view.", actionTitle: "Create workout")
                resolvedStateView(kind: .loading, title: "Loading workout", message: "Resolving the latest session.")
                resolvedStateView(kind: .error, title: "Could not load", message: "Try again when the connection is restored.", actionTitle: "Retry")
            }
            feedbackLayer
        }
    }

    private var resolvedSearchField: some View {
        if rendersWithoutScrollView {
            return AnyView(snapshotSearchField)
        }
        do {
            let searchConfiguration = try StrataSearchFieldConfiguration(
                label: "Search exercises",
                placeholder: "Search by name",
                clearLabel: "Clear search",
                resultSummary: searchText.isEmpty ? "All exercises" : "Matching exercises"
            )
            return AnyView(StrataSearchField(
                theme: configuration.theme,
                text: $searchText,
                configuration: searchConfiguration
            ))
        } catch {
            return AnyView(failureView(error))
        }
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
        if rendersWithoutScrollView {
            return AnyView(
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(configuration.theme.foreground)
                    .accessibilityLabel("More workout actions")
            )
        }
        do {
            return AnyView(try StrataMenu(
                theme: configuration.theme,
                label: "More workout actions",
                actions: [
                    StrataMenuAction(id: "duplicate", title: "Duplicate set", systemImage: "plus", handler: {}),
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
                displayValue: "8",
                prefixBadge: "80 kg",
                unitLabel: "reps",
                isActive: !isCompleted,
                isCompleted: isCompleted
            )
            return AnyView(StrataNumberSlot(
                theme: configuration.theme,
                configuration: numberSlot,
                action: { toggleSetCompletion(id) }
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
                HStack(spacing: 8) {
                    if rendersWithoutScrollView {
                        snapshotSearchField
                            .layoutPriority(1)
                    } else {
                        StrataSearchField(
                            theme: configuration.theme,
                            text: $searchText,
                            configuration: searchConfiguration
                        )
                        .layoutPriority(1)
                    }
                    StrataButton(
                        theme: configuration.theme,
                        variant: .primary,
                        surface: .solid,
                        isLoading: false,
                        action: { selectedExercise = "New exercise" },
                        label: { Text("Done").lineLimit(1).fixedSize(horizontal: true, vertical: false) },
                        loadingLabel: { Text("Adding").lineLimit(1).fixedSize(horizontal: true, vertical: false) }
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
            })
        } catch {
            return AnyView(failureView(error))
        }
    }

    private var snapshotSearchField: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(configuration.theme.secondaryForeground)
                Text(searchText.isEmpty ? "Search by name" : searchText)
                    .foregroundStyle(searchText.isEmpty ? configuration.theme.secondaryForeground : configuration.theme.foreground)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .strataSurface(theme: configuration.theme, style: configuration.surfaceStyle, cornerRadius: 16, role: .card)
            Text(searchText.isEmpty ? "All exercises" : "Matching exercises")
                .font(.footnote)
                .foregroundStyle(configuration.theme.secondaryForeground)
                .lineLimit(1)
        }
    }

    private var resolvedSlider: some View {
        if rendersWithoutScrollView {
            return AnyView(snapshotSlider)
        }
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

    @ViewBuilder
    private var selectionControls: some View {
        if rendersWithoutScrollView {
            snapshotSelectionControls
        } else {
            StrataSwitch(theme: configuration.theme, isOn: $isEnabled) {
                Text("Enable notifications").lineLimit(1)
            }
            StrataCheckbox(theme: configuration.theme, isOn: $isChecked) {
                Text("Use last weight").lineLimit(1)
            }
            resolvedRadioGroup
        }
    }

    private var snapshotSelectionControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            snapshotToggle(title: "Enable notifications", isOn: isEnabled)
            snapshotCheckbox(title: "Use last weight", isOn: isChecked)
            VStack(alignment: .leading, spacing: 6) {
                Text("Training focus")
                    .font(.subheadline.weight(.semibold))
                ForEach(["Easy", "Moderate", "Hard"], id: \.self) { value in
                    HStack(spacing: 8) {
                        Circle()
                            .stroke(value.lowercased() == selectedRadio ? configuration.theme.accent : configuration.theme.secondaryForeground, lineWidth: 2)
                            .frame(width: 18, height: 18)
                        Text(value)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private func snapshotToggle(title: String, isOn: Bool) -> some View {
        HStack {
            Text(title)
                .lineLimit(1)
            Spacer()
            Capsule()
                .fill(isOn ? configuration.theme.accent : configuration.theme.surface(.inset))
                .frame(width: 48, height: 28)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle()
                        .fill(configuration.theme.onAccent)
                        .frame(width: 22, height: 22)
                        .padding(3)
                }
        }
    }

    private func snapshotCheckbox(title: String, isOn: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(isOn ? configuration.theme.accent : configuration.theme.secondaryForeground)
            Text(title)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var resolvedProgressBar: some View {
        if rendersWithoutScrollView {
            snapshotProgressBar
        } else {
            StrataProgressBar(
                theme: configuration.theme,
                value: configuration.dataState == .loading ? nil : 68,
                total: 100,
                label: { Text("Weekly volume") },
                currentValueLabel: { Text(configuration.dataState == .loading ? "Waiting" : "68%") }
            )
        }
    }

    private var snapshotProgressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Weekly volume")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("68%")
                    .font(.caption.weight(.semibold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(configuration.theme.surface(.inset))
                    Capsule()
                        .fill(configuration.theme.accent)
                        .frame(width: proxy.size.width * 0.68)
                }
            }
            .frame(height: 10)
        }
    }

    private var snapshotSlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("RPE")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(sliderValue.formatted(.number.precision(.fractionLength(1))))
                    .font(.caption.weight(.semibold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(configuration.theme.surface(.inset))
                    Capsule()
                        .fill(configuration.theme.accent)
                        .frame(width: proxy.size.width * 0.56)
                    Circle()
                        .fill(configuration.theme.onAccent)
                        .overlay(Circle().stroke(configuration.theme.accent, lineWidth: 2))
                        .frame(width: 22, height: 22)
                        .offset(x: proxy.size.width * 0.56 - 11)
                }
            }
            .frame(height: 22)
        }
    }

    private var resolvedNotesField: some View {
        if rendersWithoutScrollView {
            return AnyView(
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.caption.weight(.semibold))
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .foregroundStyle(configuration.theme.secondaryForeground)
                        Text(notes)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .strataSurface(theme: configuration.theme, style: configuration.surfaceStyle, cornerRadius: 16, role: .card)
                }
            )
        }
        return AnyView(StrataTextField(
            theme: configuration.theme,
            text: $notes,
            prompt: Text("Exercise name"),
            label: { Text("Notes") }
        ))
    }

    private var resolvedList: some View {
        let entries = [
            ShowcaseListEntry(id: "bench", title: "Bench press", detail: "Chest · 3 sets"),
            ShowcaseListEntry(id: "row", title: "Cable row", detail: "Back · 3 sets")
        ]
        return StrataList(
            theme: configuration.theme,
            surface: configuration.surfaceStyle,
            items: entries,
            id: \.id,
            selection: .single($selectedExercise),
            header: { Text("Recent exercises") },
            leading: { _ in Image(systemName: "figure.strengthtraining.traditional") },
            primary: { entry in Text(entry.title).lineLimit(1) },
            secondary: { entry in Text(entry.detail).lineLimit(1) },
            trailing: { _ in Image(systemName: "chevron.right") },
            footer: { Text("Select an exercise to continue.") }
        )
    }

    @ViewBuilder
    private var activeDataStateView: some View {
        switch configuration.dataState {
        case .populated:
            EmptyView()
        case .empty:
            resolvedStateView(
                kind: .empty,
                title: "Nothing here",
                message: "Create a workout to populate this view.",
                actionTitle: "Restore populated",
                action: { updateConfiguration(dataState: .populated) }
            )
        case .loading:
            resolvedStateView(
                kind: .loading,
                title: "Loading workout",
                message: "Resolving the latest session.",
                actionTitle: "Restore populated",
                action: { updateConfiguration(dataState: .populated) }
            )
        case .error:
            resolvedStateView(
                kind: .error,
                title: "Could not load",
                message: "Try again when the connection is restored.",
                actionTitle: "Restore populated",
                action: { updateConfiguration(dataState: .populated) }
            )
        }
    }

    private func resolvedStateView(
        kind: StrataStateView.Kind,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        do {
            return AnyView(try StrataStateView(
                theme: configuration.theme,
                kind: kind,
                title: title,
                message: message,
                actionTitle: actionTitle,
                action: action ?? { selectedExercise = "Created" }
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

    private func toggleSetCompletion(_ id: String) {
        let wasCompleted = interaction.completedSetIDs.contains(id)
        interaction.toggleSetCompletion(id)
        if !wasCompleted {
            presentUndoSnackbar(for: id)
        }
    }

    private func presentUndoSnackbar(for id: String? = nil) {
        do {
            snackbarItem = try configuration.makeSnackbarItem {
                if let id {
                    interaction.completedSetIDs.remove(id)
                }
                interaction.isSnackbarPresented = false
            }
            interaction.isSnackbarPresented = true
        } catch {
            configurationError = String(describing: error)
        }
    }

    private func presentTimedSnackbar() {
        do {
            snackbarItem = try configuration.makeTimedSnackbarItem()
            interaction.isSnackbarPresented = true
        } catch {
            configurationError = String(describing: error)
        }
    }

    private func presentRPEDialog() {
        do {
            dialogPresentation = try configuration.makeRPEDialogPresentation { value in
                sliderValue = value
                return .dismiss
            }
            interaction.isDialogPresented = true
        } catch {
            configurationError = String(describing: error)
        }
    }
}
