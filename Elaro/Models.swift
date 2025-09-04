import SwiftUI
import SwiftData
import Foundation

// MARK: - Focus Modes tailor the app without changing the underlying data model
enum FocusMode: String, Codable, CaseIterable, Identifiable {
    case milestones   // independence/life skills (default)
    case chores       // household chores only
    case behavior     // behavior targets, habits
    case custom       // user-defined set

    var id: String { rawValue }
    var label: String {
        switch self {
        case .milestones: return "Milestones"
        case .chores:     return "Chores"
        case .behavior:   return "Behavior"
        case .custom:     return "Custom"
        }
    }

    // Which milestone kinds this mode surfaces by default
    var allowedKinds: Set<MilestoneKind> {
        switch self {
        case .milestones: return [.skill, .selfCare]
        case .chores:     return [.chore]
        case .behavior:   return [.behavior]
        case .custom:     return [.skill, .selfCare, .chore, .behavior]
        }
    }
}

enum MilestoneKind: String, Codable, CaseIterable {
    case skill      // independence skill (wipe spills, carry dishes, etc.)
    case selfCare   // dress self, place clothes in hamper
    case chore      // recurring household chores
    case behavior   // specific behavior targets (e.g., "use calm-down plan")
}

enum Category: String, Codable, CaseIterable {
    case home, selfCare, school, social, other

    var title: String {
        switch self {
        case .home:     return "Home"
        case .selfCare: return "Self Care"
        case .school:   return "School"
        case .social:   return "Social"
        case .other:    return "Other"
        }
    }
}

enum Stage: String, Codable, CaseIterable, Identifiable {
    case introduced
    case practicing
    case independent

    var id: String { rawValue }
    var label: String {
        switch self {
        case .introduced:  return "Introduced"
        case .practicing:  return "Practicing"
        case .independent: return "Independent"
        }
    }
}

// MARK: - SwiftData Models
@Model
final class Milestone {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var detail: String?
    var category: Category
    var kind: MilestoneKind
    var ageMin: Int?       // years
    var ageMax: Int?
    var tags: [String]

    init(title: String,
         detail: String? = nil,
         category: Category,
         kind: MilestoneKind,
         ageMin: Int? = nil,
         ageMax: Int? = nil,
         tags: [String] = []) {
        self.title = title
        self.detail = detail
        self.category = category
        self.kind = kind
        self.ageMin = ageMin
        self.ageMax = ageMax
        self.tags = tags
    }
}

@Model
final class ChildProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var birthdate: Date

    init(name: String, birthdate: Date) {
        self.name = name
        self.birthdate = birthdate
    }
}

@Model
final class MilestoneProgress {
    @Attribute(.unique) var id: UUID = UUID()
    var child: ChildProfile
    var milestone: Milestone
    var stage: Stage
    var notes: String?
    var weekOf: Date        // anchor to a week (e.g., Monday of that week)

    init(child: ChildProfile,
         milestone: Milestone,
         stage: Stage,
         notes: String? = nil,
         weekOf: Date) {
        self.child = child
        self.milestone = milestone
        self.stage = stage
        self.notes = notes
        self.weekOf = weekOf
    }
}

// App-level preferences that tailor the experience without altering data models.
@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID = UUID()
    var selectedModes: [FocusMode]
    var selectedChildID: UUID? // simple way to "switch child"

    init(selectedModes: [FocusMode] = [.milestones], selectedChildID: UUID? = nil) {
        self.selectedModes = selectedModes
        self.selectedChildID = selectedChildID
    }
}
