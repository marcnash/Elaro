import SwiftUI

struct TodayCard: View {
    let focus: FocusArea
    let engines: FocusEngineContainer?
    
    @State private var suggestions: [Suggestion] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isLoading {
                ProgressView("Loading suggestions...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if suggestions.isEmpty {
                VStack(spacing: 16) {
                    Text("No suggestions available")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Check back later for personalized recommendations")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Headline
                Text(suggestions.first?.headline ?? "Try this today")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                // Actions List (max 3)
                ActionsList(actions: suggestions.flatMap { $0.actions }, engines: engines, focusId: focus.id)
                
                // Explain Why Footer
                if let explainWhy = suggestions.first?.explainWhy {
                    ExplainWhyFooter(explainWhy: explainWhy)
                }
                
                Spacer(minLength: 0)
            }
        }
        .onAppear {
            loadSuggestions()
        }
        .onChange(of: focus) {
            loadSuggestions()
        }
    }
    
    private func loadSuggestions() {
        guard let engines = engines else { return }
        
        isLoading = true
        DispatchQueue.main.async {
            let newSuggestions = engines.recommender.rank(for: focus.id, day: Date.now)
            self.suggestions = newSuggestions
            self.isLoading = false
        }
    }
}

#Preview("Independence") {
    TodayCard(focus: FocusArea(id: "independence", name: "Independence"), engines: nil)
}

#Preview("Emotion Skills") {
    TodayCard(focus: FocusArea(id: "emotion_skills", name: "Emotion Skills"), engines: nil)
}
