import SwiftUI

struct ThisWeekCard: View {
    let focus: FocusArea
    
    private var weeklySummary: WeeklySummary {
        MockContent.weeklySummary(for: focus)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("This Week in \(focus.displayName)")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Win • What's Hard • Suggested Tweak
            WinHardTweakView(weeklySummary: weeklySummary)
            
            // Mini-ritual cadence picker
            MiniRitualPicker()
            
            Spacer(minLength: 0)
        }
    }
}

struct WinHardTweakView: View {
    let weeklySummary: WeeklySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Win
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Win")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(weeklySummary.winText)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            // What's Hard
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("What's Hard")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(weeklySummary.hardText)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            // Suggested Tweak
            VStack(alignment: .leading, spacing: 12) {
                Text("Suggested tweak:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    TweakButton(
                        title: "Keep",
                        isSelected: weeklySummary.suggestedTweak == .keep,
                        onTap: { print("Keep selected") }
                    )
                    
                    TweakButton(
                        title: "Scale down",
                        isSelected: weeklySummary.suggestedTweak == .scaleDown,
                        onTap: { print("Scale down selected") }
                    )
                    
                    TweakButton(
                        title: "Scale up",
                        isSelected: weeklySummary.suggestedTweak == .scaleUp,
                        onTap: { print("Scale up selected") }
                    )
                }
            }
        }
    }
}

struct TweakButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? .blue : .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.blue, lineWidth: isSelected ? 0 : 1)
                        )
                )
                .foregroundColor(isSelected ? .white : .blue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tweak: \(title)")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct MiniRitualPicker: View {
    @State private var selectedCadence: RitualCadence = .none
    
    enum RitualCadence: String, CaseIterable {
        case none = "none"
        case once = "once"
        case twice = "twice"
        
        var displayName: String {
            switch self {
            case .none:
                return "None"
            case .once:
                return "1×/week"
            case .twice:
                return "2×/week"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mini-ritual cadence:")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 8) {
                ForEach(RitualCadence.allCases, id: \.self) { cadence in
                    Button(action: {
                        selectedCadence = cadence
                        print("Selected cadence: \(cadence.displayName)")
                    }) {
                        Text(cadence.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedCadence == cadence ? .blue : .clear)
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(.blue, lineWidth: selectedCadence == cadence ? 0 : 1)
                                    )
                            )
                            .foregroundColor(selectedCadence == cadence ? .white : .blue)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cadence: \(cadence.displayName)")
                    .accessibilityHint(selectedCadence == cadence ? "Selected" : "Tap to select")
                    .accessibilityAddTraits(selectedCadence == cadence ? .isSelected : [])
                }
            }
        }
    }
}

#Preview("Independence") {
    ThisWeekCard(focus: .independence)
}

#Preview("Emotion Skills") {
    ThisWeekCard(focus: .emotionSkills)
}
