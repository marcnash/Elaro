import SwiftUI

struct FocusDeckScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFocus: FocusKey = .independence
    @State private var depth: FocusDepth? = .today
    @State private var engines: FocusEngineContainer?
    @State private var showDebug = false
    @State private var lastWhy = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FocusUtilityBar(
                    selectedFocus: $selectedFocus,
                    depth: Binding(
                        get: { depth ?? .today },
                        set: { depth = $0 }
                    )
                )
                
                // Horizontal deck pager
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(FocusDepth.allCases, id: \.self) { focusDepth in
                            CardContainer {
                                switch focusDepth {
                                case .today:
                                    TodayCard(focus: focusAreaFor(selectedFocus), engines: engines)
                                case .week:
                                    ThisWeekCard(focus: focusAreaFor(selectedFocus), engines: engines)
                                case .month:
                                    MonthlyPlanCard(focus: focusAreaFor(selectedFocus), engines: engines)
                                case .season:
                                    SeasonCard(focus: focusAreaFor(selectedFocus), engines: engines)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                }
                .scrollTargetLayout()
                .scrollPosition(id: $depth)
                .scrollTargetBehavior(.paging)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
            .onLongPressGesture {
                showDebug.toggle()
            }
            .overlay(alignment: .topLeading) {
                if showDebug {
                    EngineDebugOverlay(
                        focusId: selectedFocus.rawValue,
                        actionCount: engines?.store.actions(for: selectedFocus.rawValue).count ?? 0,
                        why: lastWhy
                    )
                }
            }
            .onAppear {
                if engines == nil {
                    engines = FocusEngineContainer(modelContext: modelContext)
                }
            }
            .onChange(of: selectedFocus) {
                updateDebugInfo()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func focusAreaFor(_ focusKey: FocusKey) -> FocusArea {
        return FocusArea(
            id: focusKey.rawValue,
            name: focusKey.displayName,
            active: true,
            startedAt: Date.now,
            buildingBlocks: [],
            pinnedMicroSkillTitles: []
        )
    }
    
    private func updateDebugInfo() {
        guard let engines = engines else { return }
        let suggestions = engines.recommender.rank(for: selectedFocus.rawValue)
        lastWhy = suggestions.first?.whySummary ?? ""
    }
}

#Preview {
    FocusDeckScreen()
}