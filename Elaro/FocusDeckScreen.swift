import SwiftUI

struct FocusDeckScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFocus: FocusKey = .independence
    @State private var depth: FocusDepth? = .today
    @State private var engines: FocusEngineContainer?
    
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
            .onAppear {
                if engines == nil {
                    engines = FocusEngineContainer(modelContext: modelContext)
                }
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
}

#Preview {
    FocusDeckScreen()
}