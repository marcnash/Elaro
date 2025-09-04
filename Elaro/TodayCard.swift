import SwiftUI

struct TodayCard: View {
    let focus: FocusArea
    
    private var suggestion: Suggestion {
        MockContent.suggestion(for: focus)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Headline
            Text(suggestion.headline)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            // Actions List (max 3)
            ActionsList(actions: suggestion.actions)
            
            // Explain Why Footer
            ExplainWhyFooter(explainWhy: suggestion.explainWhy)
            
            Spacer(minLength: 0)
        }
    }
}

#Preview("Independence") {
    TodayCard(focus: .independence)
}

#Preview("Emotion Skills") {
    TodayCard(focus: .emotionSkills)
}
