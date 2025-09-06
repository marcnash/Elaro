import SwiftUI

struct FocusDeckScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFocus: FocusKey = .independence
    @State private var depth: DepthRail.Depth = .today
    @State private var scrollPos: DepthRail.Depth? = .today
    @State private var engines: FocusEngineContainer?
    @State private var showDebug = false
    @State private var lastWhy = ""
    @AppStorage("seenDepthCoach") private var seenDepthCoach = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                FocusUtilityBar(
                    selectedFocus: $selectedFocus,
                    depth: Binding(
                        get: { focusDepthFor(depth) },
                        set: { depth = depthRailFor($0) }
                    )
                )
                
                DepthRail(selection: $depth)
                    .padding(.horizontal)
                    .padding(.top, 6)
                
                // Horizontal deck pager
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        CardContainer {
                            TodayCard(focus: focusAreaFor(selectedFocus), engines: engines)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(DepthRail.Depth.today)
                        
                        CardContainer {
                            ThisWeekCard(focus: focusAreaFor(selectedFocus), engines: engines)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(DepthRail.Depth.week)
                        
                        CardContainer {
                            MonthlyPlanCard(focus: focusAreaFor(selectedFocus), engines: engines)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(DepthRail.Depth.month)
                        
                        CardContainer {
                            SeasonCard(focus: focusAreaFor(selectedFocus), engines: engines)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(DepthRail.Depth.season)
                    }
                }
                .scrollTargetLayout()
                .scrollPosition(id: $scrollPos)
                .scrollIndicators(.never)
                .scrollTargetBehavior(.paging)
                .onChange(of: depth) { _, newVal in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { scrollPos = newVal }
                }
                .onChange(of: scrollPos) { _, newVal in
                    if let newVal { depth = newVal }
                }
                .overlay {
                    EdgeFades(showLeft: depth != .today, showRight: depth != .season)
                }
                
                // Bottom dots
                DepthDots(selection: $depth)
                    .padding(.bottom, 6)
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
            .overlay(alignment: .bottom) {
                if !seenDepthCoach {
                    CoachMark().onDisappear { seenDepthCoach = true }
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
    
    private func updateDebugInfo() {
        guard let engines = engines else { return }
        let suggestions = engines.recommender.rank(for: selectedFocus.rawValue)
        lastWhy = suggestions.first?.whySummary ?? ""
    }
    
    private func focusDepthFor(_ depthRail: DepthRail.Depth) -> FocusDepth {
        switch depthRail {
        case .today: return .today
        case .week: return .week
        case .month: return .month
        case .season: return .season
        }
    }
    
    private func depthRailFor(_ focusDepth: FocusDepth) -> DepthRail.Depth {
        switch focusDepth {
        case .today: return .today
        case .week: return .week
        case .month: return .month
        case .season: return .season
        }
    }
}

#Preview {
    FocusDeckScreen()
}