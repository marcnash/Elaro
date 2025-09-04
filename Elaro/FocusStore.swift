import Foundation
import SwiftData

@Observable
class FocusStore {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Action Templates
    
    func actions(for focusId: String) -> [ActionTemplate] {
        do {
            let predicate = #Predicate<ActionTemplate> { template in
                template.focusId == focusId
            }
            let descriptor = FetchDescriptor<ActionTemplate>(predicate: predicate)
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch actions for focus \(focusId): \(error)")
            return []
        }
    }
    
    func allActions() -> [ActionTemplate] {
        do {
            let descriptor = FetchDescriptor<ActionTemplate>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch all actions: \(error)")
            return []
        }
    }
    
    // MARK: - Action Instances
    
    func actionInstances(in range: DateInterval, focusId: String? = nil) -> [ActionInstance] {
        do {
            let predicate: Predicate<ActionInstance>
            if let focusId = focusId {
                predicate = #Predicate<ActionInstance> { instance in
                    instance.date >= range.start && instance.date <= range.end && instance.focusId == focusId
                }
            } else {
                predicate = #Predicate<ActionInstance> { instance in
                    instance.date >= range.start && instance.date <= range.end
                }
            }
            
            let descriptor = FetchDescriptor<ActionInstance>(predicate: predicate)
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch action instances: \(error)")
            return []
        }
    }
    
    @MainActor
    func save(instance: ActionInstance) {
        do {
            modelContext.insert(instance)
            try modelContext.save()
        } catch {
            print("Failed to save action instance: \(error)")
        }
    }
    
    // MARK: - Weekly Summaries
    
    func summaries(for focusId: String, limit: Int = 10) -> [WeeklySummary] {
        do {
            let predicate = #Predicate<WeeklySummary> { summary in
                summary.focusId == focusId
            }
            var descriptor = FetchDescriptor<WeeklySummary>(predicate: predicate)
            descriptor.sortBy = [SortDescriptor(\.weekStart, order: .reverse)]
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch summaries for focus \(focusId): \(error)")
            return []
        }
    }
    
    @MainActor
    func save(summary: WeeklySummary) {
        do {
            modelContext.insert(summary)
            try modelContext.save()
        } catch {
            print("Failed to save weekly summary: \(error)")
        }
    }
    
    // MARK: - Focus Areas
    
    func focus(by id: String) -> FocusArea? {
        do {
            let predicate = #Predicate<FocusArea> { focus in
                focus.id == id
            }
            let descriptor = FetchDescriptor<FocusArea>(predicate: predicate)
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to fetch focus by id \(id): \(error)")
            return nil
        }
    }
    
    func allFocuses() -> [FocusArea] {
        do {
            let descriptor = FetchDescriptor<FocusArea>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch all focuses: \(error)")
            return []
        }
    }
    
    func activeFocuses() -> [FocusArea] {
        do {
            let predicate = #Predicate<FocusArea> { focus in
                focus.active == true
            }
            let descriptor = FetchDescriptor<FocusArea>(predicate: predicate)
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch active focuses: \(error)")
            return []
        }
    }
    
    @MainActor
    func upsert(focus: FocusArea) {
        do {
            // Check if focus already exists
            if let existing = self.focus(by: focus.id) {
                // Update existing
                existing.name = focus.name
                existing.active = focus.active
                existing.startedAt = focus.startedAt
                existing.buildingBlocks = focus.buildingBlocks
                existing.pinnedMicroSkillTitles = focus.pinnedMicroSkillTitles
            } else {
                // Insert new
                modelContext.insert(focus)
            }
            try modelContext.save()
        } catch {
            print("Failed to upsert focus: \(error)")
        }
    }
    
    // MARK: - Building Blocks
    
    @MainActor
    func updateBuildingBlocks(for focusId: String, blocks: [BuildingBlock]) {
        guard let focus = focus(by: focusId) else {
            print("Focus not found: \(focusId)")
            return
        }
        
        focus.buildingBlocks = blocks
        do {
            try modelContext.save()
        } catch {
            print("Failed to update building blocks: \(error)")
        }
    }
    
    @MainActor
    func updatePinnedMicroSkills(for focusId: String, pinnedTitles: [String]) {
        guard let focus = focus(by: focusId) else {
            print("Focus not found: \(focusId)")
            return
        }
        
        focus.pinnedMicroSkillTitles = pinnedTitles
        do {
            try modelContext.save()
        } catch {
            print("Failed to update pinned micro skills: \(error)")
        }
    }
}
