import SwiftUI

struct SeasonCard: View {
    let focus: FocusArea
    
    private var seasonSummary: SeasonSummary {
        MockContent.seasonSummary(for: focus)
    }
    
    @State private var storyText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Season: \(focus.displayName)")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Theme Evolution
            VStack(alignment: .leading, spacing: 8) {
                Text("Theme evolution:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(seasonSummary.themeEvolution)
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
                    ForEach(seasonSummary.rungs, id: \.self) { rung in
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
                Text(seasonSummary.storyPrompt)
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
                preview: seasonSummary.nextSeasonPreview,
                onAccept: {
                    print("Next season accepted")
                },
                onKeep: {
                    print("Keep current season")
                }
            )
            
            Spacer(minLength: 0)
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
    SeasonCard(focus: .independence)
}

#Preview("Emotion Skills") {
    SeasonCard(focus: .emotionSkills)
}
