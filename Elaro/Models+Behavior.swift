import SwiftData
import Foundation

@Model
final class BehaviorPlanTemplate {
    @Attribute(.unique) var id: UUID = UUID()
    var milestone: Milestone               // must be .behavior kind
    var stepTemplates: [BehaviorStepTemplate]      // ordered

    init(milestone: Milestone, steps: [BehaviorStepTemplate]) {
        self.milestone = milestone
        self.stepTemplates = steps
    }
}

@Model
final class BehaviorStepTemplate {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var order: Int

    init(title: String, order: Int) {
        self.title = title
        self.order = order
    }
}

@Model
final class BehaviorPlanProgress {
    @Attribute(.unique) var id: UUID = UUID()
    var child: ChildProfile
    var milestone: Milestone
    var weekOf: Date
    var stepProgresses: [BehaviorStepProgress]      // per-week checkboxes
    var notes: String?

    init(child: ChildProfile, milestone: Milestone, weekOf: Date, steps: [BehaviorStepProgress], notes: String? = nil) {
        self.child = child
        self.milestone = milestone
        self.notes = notes
        self.weekOf = weekOf
        self.stepProgresses = steps
    }
}

@Model
final class BehaviorStepProgress {
    @Attribute(.unique) var id: UUID = UUID()
    var template: BehaviorStepTemplate
    var isDone: Bool

    init(template: BehaviorStepTemplate, isDone: Bool = false) {
        self.template = template
        self.isDone = isDone
    }
}
