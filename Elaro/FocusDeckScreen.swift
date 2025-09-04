import SwiftUI

struct FocusDeckScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFocus: FocusArea = FocusArea(id: "independence", name: "Independence")
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
                                    TodayCard(focus: selectedFocus, engines: engines)
                                case .week:
                                    ThisWeekCard(focus: selectedFocus, engines: engines)
                                case .month:
                                    MonthlyPlanCard(focus: selectedFocus, engines: engines)
                                case .season:
                                    SeasonCard(focus: selectedFocus, engines: engines)
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
}

#Preview {
    FocusDeckScreen()
}