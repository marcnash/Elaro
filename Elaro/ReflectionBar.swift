import SwiftUI

struct ReflectionBar: View {
    @State private var selectedDifficulty: DifficultyLevel? = nil
    @State private var note: String = ""
    
    enum DifficultyLevel: String, CaseIterable {
        case light = "light"
        case ok = "ok"
        case hard = "hard"
        
        var displayName: String {
            switch self {
            case .light:
                return "Light"
            case .ok:
                return "OK"
            case .hard:
                return "Hard"
            }
        }
        
        var color: Color {
            switch self {
            case .light:
                return .green
            case .ok:
                return .orange
            case .hard:
                return .red
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did this feel?")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        onTap: {
                            selectedDifficulty = difficulty
                            print("Selected difficulty: \(difficulty.displayName)")
                        }
                    )
                }
                
                Spacer()
            }
            
            // Optional note field
            if selectedDifficulty != nil {
                TextField("Optional note...", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .font(.caption)
            }
        }
    }
}

struct DifficultyButton: View {
    let difficulty: ReflectionBar.DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(difficulty.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? difficulty.color : .clear)
                        .overlay(
                            Capsule()
                                .strokeBorder(difficulty.color, lineWidth: isSelected ? 0 : 1)
                        )
                )
                .foregroundColor(isSelected ? .white : difficulty.color)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Difficulty: \(difficulty.displayName)")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        ReflectionBar()
    }
    .padding()
}
