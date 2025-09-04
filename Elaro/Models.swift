import SwiftData
import Foundation

// MARK: - SwiftData Models

@Model final class FocusArea {
    @Attribute(.unique) var id: String // e.g., "independence", "emotion_skills"
    var name: String
    var active: Bool
    var startedAt: Date
    var buildingBlocks: [BuildingBlock] // exactly 3 when configured
    var pinnedMicroSkillTitles: [String] // influence recommender
    
    init(id: String, name: String, active: Bool = true, startedAt: Date = Date.now, buildingBlocks: [BuildingBlock] = [], pinnedMicroSkillTitles: [String] = []) {
        self.id = id
        self.name = name
        self.active = active
        self.startedAt = startedAt
        self.buildingBlocks = buildingBlocks
        self.pinnedMicroSkillTitles = pinnedMicroSkillTitles
    }
}

@Model final class BuildingBlock {
    var type: String // microSkill | ritual | support
    var title: String
    var desc: String?
    var tags: [String]
    
    init(type: String, title: String, desc: String? = nil, tags: [String] = []) {
        self.type = type
        self.title = title
        self.desc = desc
        self.tags = tags
    }
}

@Model final class ActionTemplate {
    @Attribute(.unique) var id: String // stable id from seed
    var focusId: String // FK → FocusArea.id
    var title: String
    var whyLine: String
    var tags: [String]
    var difficulty: Int // 1..5
    var variants: [TemplateVariant]
    var contraindications: [String]
    var contentVersion: Int
    
    init(id: String, focusId: String, title: String, whyLine: String, tags: [String] = [], difficulty: Int = 1, variants: [TemplateVariant] = [], contraindications: [String] = [], contentVersion: Int = 1) {
        self.id = id
        self.focusId = focusId
        self.title = title
        self.whyLine = whyLine
        self.tags = tags
        self.difficulty = difficulty
        self.variants = variants
        self.contraindications = contraindications
        self.contentVersion = contentVersion
    }
}

@Model final class TemplateVariant {
    var durationMinutes: Int // 5|10|20
    var steps: [String]
    
    init(durationMinutes: Int, steps: [String]) {
        self.durationMinutes = durationMinutes
        self.steps = steps
    }
}

@Model final class ActionInstance {
    @Attribute(.unique) var id: String
    var date: Date // day bucket
    var focusId: String
    var templateId: String
    var variantDuration: Int // 5|10|20
    var status: String // done | snoozed | skipped
    var feltDifficulty: String? // light | ok | hard
    var mood: String?
    var note: String?
    
    init(id: String, date: Date, focusId: String, templateId: String, variantDuration: Int, status: String, feltDifficulty: String? = nil, mood: String? = nil, note: String? = nil) {
        self.id = id
        self.date = date
        self.focusId = focusId
        self.templateId = templateId
        self.variantDuration = variantDuration
        self.status = status
        self.feltDifficulty = feltDifficulty
        self.mood = mood
        self.note = note
    }
}

@Model final class WeeklySummary {
    @Attribute(.unique) var id: String
    var weekStart: Date
    var focusId: String
    var winText: String
    var hardText: String
    var suggestedTweak: String // keep | scale_down | scale_up
    
    init(id: String, weekStart: Date, focusId: String, winText: String, hardText: String, suggestedTweak: String) {
        self.id = id
        self.weekStart = weekStart
        self.focusId = focusId
        self.winText = winText
        self.hardText = hardText
        self.suggestedTweak = suggestedTweak
    }
}

// MARK: - Supporting Types

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

struct Suggestion: Identifiable {
    let id = UUID()
    let focus: FocusArea
    let headline: String
    let actions: [ActionTemplate]
    let explainWhy: String
}

struct SeasonSummary {
    let themeEvolution: String
    let rungs: [String]
    let storyPrompt: String
    let nextSeasonPreview: String
}