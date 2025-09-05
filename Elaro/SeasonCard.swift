import SwiftUI

struct SeasonCard: View {
    let focus: FocusArea
    let engines: FocusEngineContainer?
    
    @State private var storyText: String = ""
    @State private var seasonSummary: SeasonSummary?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Season: \(focus.name)")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isLoading {
                ProgressView("Loading season...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let summary = seasonSummary {
                // Theme Evolution
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme evolution:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(summary.themeEvolution)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                
                // 2-3 Rungs
                VStack(alignment: .leading, spacing: 12) {
                    Text("Competency rungs touched:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(summary.rungs, id: \.self) { rung in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                
                                Text(rung)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                
                // Story Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.storyPrompt)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $storyText)
                        .font(.body)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                // Next Season Preview
                NextSeasonPreview(
                    preview: summary.nextSeasonPreview,
                    onAccept: {
                        print("Next season accepted")
                    },
                    onKeep: {
                        print("Keep current season")
                    }
                )
            } else {
                VStack(spacing: 16) {
                    Text("No season data available")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Complete some activities to see your season summary")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            loadSeasonSummary()
        }
        .onChange(of: focus) {
            loadSeasonSummary()
        }
    }
    
    private func loadSeasonSummary() {
        guard let engines = engines else { return }
        
        isLoading = true
        DispatchQueue.main.async {
            // For now, use mock data. In a real implementation, this would
            // analyze the user's progress and generate a season summary
            let summary = MockContent.seasonSummary(for: focus)
            self.seasonSummary = summary
            self.isLoading = false
        }
    }
}

struct NextSeasonPreview: View {
    let preview: String
    let onAccept: () -> Void
    let onKeep: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next season preview:")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(preview)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(12)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            
            HStack(spacing: 12) {
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Accept next season")
                .accessibilityHint("Accept the proposed next season focus")
                
                Button(action: onKeep) {
                    Text("Keep")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.clear, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.blue, lineWidth: 1)
                        )
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Keep current season")
                .accessibilityHint("Keep the current season focus")
            }
        }
    }
}

#Preview("Independence") {
    SeasonCard(focus: FocusArea(id: FocusKey.independence.rawValue, name: FocusKey.independence.displayName), engines: nil)
}

#Preview("Emotion Skills") {
    SeasonCard(focus: FocusArea(id: FocusKey.emotionSkills.rawValue, name: FocusKey.emotionSkills.displayName), engines: nil)
}
