import Foundation

// MARK: - UI-Only Focus Key Enum
// This is a UI-only enum for focus area pills and selections
// It does NOT conflict with the SwiftData FocusArea model

enum FocusKey: String, CaseIterable, Identifiable {
    case independence = "independence"
    case emotionSkills = "emotion_skills"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .independence:
            return "Independence"
        case .emotionSkills:
            return "Emotion Skills"
        }
    }
    
    var description: String {
        switch self {
        case .independence:
            return "Building autonomy and self-reliance"
        case .emotionSkills:
            return "Developing emotional awareness and regulation"
        }
    }
    
    var color: String {
        switch self {
        case .independence:
            return "blue"
        case .emotionSkills:
            return "green"
        }
    }
}
