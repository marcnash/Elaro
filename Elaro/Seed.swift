import SwiftData
import Foundation

@MainActor
func seedIfNeeded(modelContext: ModelContext) async {
    let settingsFetch = FetchDescriptor<AppSettings>()
    if (try? modelContext.fetch(settingsFetch))?.isEmpty ?? true {
        modelContext.insert(AppSettings(selectedModes: [.milestones]))
    }

    let childrenFetch = FetchDescriptor<ChildProfile>()
    let hasChild = ((try? modelContext.fetch(childrenFetch))?.isEmpty ?? true) == false
    if !hasChild {
        modelContext.insert(ChildProfile(name: "Alex", birthdate: Calendar.current.date(byAdding: .year, value: -4, to: Date.now)!))
    }

    let milestoneFetch = FetchDescriptor<Milestone>()
    let hasMilestones = ((try? modelContext.fetch(milestoneFetch))?.isEmpty ?? true) == false
    if !hasMilestones {
        // A tiny starter set; expand with your full Fridge Chart
        let items: [Milestone] = [
            Milestone(title: "Put toys back in bin",
                      detail: "End of playtime routine",
                      category: .home, kind: .skill, ageMin: 2, ageMax: 3, tags: ["tidy","routine"]),
            Milestone(title: "Place dirty clothes in hamper",
                      category: .selfCare, kind: .selfCare, ageMin: 2, ageMax: 3, tags: ["laundry"]),
            Milestone(title: "Wipe small spills with cloth",
                      category: .home, kind: .skill, ageMin: 2, ageMax: 3, tags: ["cleanup"]),
            Milestone(title: "Carry plastic dishes to counter",
                      category: .home, kind: .chore, ageMin: 2, ageMax: 3, tags: ["dishes"]),
            Milestone(title: "Make bed (simple)",
                      category: .selfCare, kind: .chore, ageMin: 4, ageMax: 5, tags: ["morning"]),
            // Behavior examples
            Milestone(title: "Use calm-down plan when upset",
                      detail: "Pick from: breathe, count, move",
                      category: .other, kind: .behavior, ageMin: 4, ageMax: 8, tags: ["regulation","SEL"])
        ]
        items.forEach { modelContext.insert($0) }
    }

    // Seed behavior plan template for the calm-down milestone
    if let calm = (try? modelContext.fetch(FetchDescriptor<Milestone>()))?.first(where: { $0.title == "Use calm-down plan when upset" }) {
        let hasTemplate = ((try? modelContext.fetch(FetchDescriptor<BehaviorPlanTemplate>()))?.contains(where: { $0.milestone.id == calm.id })) ?? false
        if !hasTemplate {
            let steps = [
                BehaviorStepTemplate(title: "Name the feeling", order: 0),
                BehaviorStepTemplate(title: "Breathe 5 times", order: 1),
                BehaviorStepTemplate(title: "Ask for space or help", order: 2),
                BehaviorStepTemplate(title: "Rejoin + reflect", order: 3)
            ]
            steps.forEach { modelContext.insert($0) }
            modelContext.insert(BehaviorPlanTemplate(milestone: calm, steps: steps))
        }
    }

    try? modelContext.save()
}
