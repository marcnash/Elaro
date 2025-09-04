import Foundation

// MARK: - Phase 1 Models (No Persistence)

enum FocusArea: String, CaseIterable, Identifiable {
    case independence = "independence"
    case emotionSkills = "emotionSkills"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .independence:
            return "Independence"
        case .emotionSkills:
            return "Emotion Skills"
        }
    }
}

enum FocusDepth: CaseIterable {
    case today
    case week
    case month
    case season
    
    var displayName: String {
        switch self {
        case .today:
            return "Today"
        case .week:
            return "This Week"
        case .month:
            return "Monthly Plan"
        case .season:
            return "Season"
        }
    }
}

struct ActionVariant: Identifiable {
    let id = UUID()
    let durationMinutes: Int
    let steps: [String]
}

struct ActionTemplate: Identifiable {
    let id = UUID()
    let title: String
    let whyLine: String
    let variants: [ActionVariant] // 5/10/20
}

struct Suggestion: Identifiable {
    let id = UUID()
    let focus: FocusArea
    let headline: String // "Try this today…"
    let actions: [ActionTemplate] // 1–3
    let explainWhy: String // e.g., "Because evenings worked…"
}

// MARK: - Weekly Summary Models

struct WeeklySummary {
    let winText: String
    let hardText: String
    let suggestedTweak: TweakSuggestion
}

enum TweakSuggestion {
    case keep
    case scaleDown
    case scaleUp
    
    var displayName: String {
        switch self {
        case .keep:
            return "Keep"
        case .scaleDown:
            return "Scale down"
        case .scaleUp:
            return "Scale up"
        }
    }
}

// MARK: - Monthly Plan Models

struct BuildingBlock: Identifiable {
    let id = UUID()
    let type: BuildingBlockType
    var title: String
    var description: String
    var isPinned: Bool = false
}

enum BuildingBlockType {
    case microSkill
    case ritual
    case support
    
    var displayName: String {
        switch self {
        case .microSkill:
            return "Micro-skill"
        case .ritual:
            return "Ritual"
        case .support:
            return "Support"
        }
    }
}

// MARK: - Season Models

struct SeasonSummary {
    let themeEvolution: String
    let rungs: [String]
    let storyPrompt: String
    let nextSeasonPreview: String
}