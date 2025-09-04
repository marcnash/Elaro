import SwiftUI
import SwiftData
import Foundation

struct BehaviorPlanPanel: View {
    @Environment(\.modelContext) private var ctx

    // Fetch everything; we'll filter in code to avoid predicate compilation issues
    @Query private var allTemplates: [BehaviorPlanTemplate]
    @Query private var allPlans: [BehaviorPlanProgress]

    let milestone: Milestone
    let child: ChildProfile
    let weekOf: Date

    // Normalize to start-of-week so we keep one record per week
    private var weekStart: Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekOf)) ?? weekOf
    }
    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
    }

    private var template: BehaviorPlanTemplate? {
        // Compare by our explicit UUIDs (defined in the @Model types)
        // Use computed property to avoid predicate compilation issues
        return allTemplates.first { template in
            template.milestone.id == milestone.id
        }
    }

    private var plan: BehaviorPlanProgress? {
        // Use computed property to avoid predicate compilation issues
        return allPlans.first { plan in
            plan.child.id == child.id &&
            plan.milestone.id == milestone.id &&
            plan.weekOf >= weekStart && plan.weekOf < weekEnd
        }
    }

    var body: some View {
        Group {
            if template != nil {
                DisclosureGroup("Behavior Plan") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sortedSteps(), id: \.id) { step in
                            CheckRow(
                                title: step.template.title,
                                isOn: step.isDone
                            ) {
                                toggle(step)
                            }
                        }
                    }
                    .task { ensureWeeklyPlan() }
                }
                .font(.caption)
            } else {
                Text("No behavior plan defined for this milestone.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Create a weekly plan instance if one doesn't exist yet
    private func ensureWeeklyPlan() {
        guard plan == nil, let template else { return }

        let steps = template.stepTemplates
            .sorted(by: { $0.order < $1.order })
            .map { BehaviorStepProgress(template: $0) }

        let newPlan = BehaviorPlanProgress(
            child: child,
            milestone: milestone,
            weekOf: weekStart,
            steps: steps
        )
        ctx.insert(newPlan)
        try? ctx.save()
    }

    private func sortedSteps() -> [BehaviorStepProgress] {
        guard let plan else { return [] }
        return plan.stepProgresses.sorted { $0.template.order < $1.template.order }
    }

    private func toggle(_ step: BehaviorStepProgress) {
        step.isDone.toggle()
        try? ctx.save()
    }
}

// MARK: - iOS-friendly check row (no .checkbox on iOS)
private struct CheckRow: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                Text(title).font(.callout)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
