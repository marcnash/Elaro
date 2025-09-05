import SwiftUI

struct ThisWeekCard: View {
    let focus: FocusArea
    let engines: FocusEngineContainer?
    
    @State private var weeklyAnalysis: WeeklyAnalysis?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("This Week in \(focus.name)")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isLoading {
                ProgressView("Analyzing week...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let analysis = weeklyAnalysis {
                // Win • What's Hard • Suggested Tweak
                WinHardTweakView(analysis: analysis, engines: engines)
                
                // Mini-ritual cadence picker
                MiniRitualPicker()
            } else {
                VStack(spacing: 16) {
                    Text("No data for this week")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Complete some actions to see your weekly summary")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            loadWeeklyAnalysis()
        }
        .onChange(of: focus) {
            loadWeeklyAnalysis()
        }
    }
    
    private func loadWeeklyAnalysis() {
        guard let engines = engines else { return }
        
        isLoading = true
        DispatchQueue.main.async {
            let weekStart = getCurrentWeekStart()
            let analysis = engines.weeklyAdjuster.analyzeWeek(for: focus.id, weekStart: weekStart)
            self.weeklyAnalysis = analysis
            self.isLoading = false
        }
    }
    
    private func getCurrentWeekStart() -> Date {
        let calendar = Calendar.current
        let now = Date.now
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.year, from: now)
        
        var components = DateComponents()
        components.weekOfYear = weekOfYear
        components.yearForWeekOfYear = year
        components.weekday = calendar.firstWeekday
        
        return calendar.date(from: components) ?? now
    }
}

struct WinHardTweakView: View {
    let analysis: WeeklyAnalysis
    let engines: FocusEngineContainer?
    
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
                
                Text(analysis.winText)
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
                
                Text(analysis.hardText)
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
                
                Text(analysis.rationale)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                
                HStack(spacing: 12) {
                    TweakButton(
                        title: "Keep",
                        isSelected: analysis.suggestedTweak == .keep,
                        onTap: { 
                            engines?.weeklyAdjuster.applyTweak(.keep, for: analysis.focusId)
                        }
                    )
                    
                    TweakButton(
                        title: "Scale down",
                        isSelected: analysis.suggestedTweak == .scaleDown,
                        onTap: { 
                            engines?.weeklyAdjuster.applyTweak(.scaleDown, for: analysis.focusId)
                        }
                    )
                    
                    TweakButton(
                        title: "Scale up",
                        isSelected: analysis.suggestedTweak == .scaleUp,
                        onTap: { 
                            engines?.weeklyAdjuster.applyTweak(.scaleUp, for: analysis.focusId)
                        }
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
    ThisWeekCard(focus: FocusArea(id: FocusKey.independence.rawValue, name: FocusKey.independence.displayName), engines: nil)
}

#Preview("Emotion Skills") {
    ThisWeekCard(focus: FocusArea(id: FocusKey.emotionSkills.rawValue, name: FocusKey.emotionSkills.displayName), engines: nil)
}
