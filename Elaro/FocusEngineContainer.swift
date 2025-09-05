import SwiftUI
import SwiftData

@Observable
@MainActor
class FocusEngineContainer {
    let store: FocusStore
    let signals: SignalsEngine
    let recommender: RecommenderEngine
    let weeklyAdjuster: WeeklyAdjuster
    let focusPlanner: FocusPlanner
    let explainWhyBuilder: ExplainWhyBuilder
    
    init(modelContext: ModelContext) {
        self.store = FocusStore(modelContext: modelContext)
        self.signals = SignalsEngine(store: store)
        self.explainWhyBuilder = ExplainWhyBuilder()
        self.recommender = RecommenderEngine(store: store, signals: signals, explain: explainWhyBuilder)
        self.weeklyAdjuster = WeeklyAdjuster(store: store)
        self.focusPlanner = FocusPlanner(store: store)
    }
}

// MARK: - Environment Key

private struct FocusEngineContainerKey: EnvironmentKey {
    static let defaultValue: FocusEngineContainer? = nil
}

extension EnvironmentValues {
    var focusEngines: FocusEngineContainer? {
        get { self[FocusEngineContainerKey.self] }
        set { self[FocusEngineContainerKey.self] = newValue }
    }
}
