import Foundation
import SwiftData

struct SeedImporter {
    static func run(modelContext: ModelContext) async {
        // Check if we've already imported this version
        let userDefaults = UserDefaults.standard
        let importedVersionKey = "seedContentVersion"
        let currentVersion = 1
        
        if userDefaults.integer(forKey: importedVersionKey) >= currentVersion {
            print("Seed content already imported (version \(currentVersion))")
            return
        }
        
        do {
            // Load seed data
            guard let seedData = loadSeedData() else {
                print("Failed to load seed data")
                return
            }
            
            // Import action templates
            try await importActionTemplates(seedData, modelContext: modelContext)
            
            // Create default focus areas if they don't exist
            try await createDefaultFocusAreas(modelContext: modelContext)
            
            // Mark as imported
            userDefaults.set(currentVersion, forKey: importedVersionKey)
            print("Seed content imported successfully (version \(currentVersion))")
            
        } catch {
            print("Failed to import seed content: \(error)")
        }
    }
    
    private static func loadSeedData() -> SeedData? {
        guard let url = Bundle.main.url(forResource: "actions_seed", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find actions_seed.json in bundle")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(SeedData.self, from: data)
        } catch {
            print("Failed to decode seed data: \(error)")
            return nil
        }
    }
    
    private static func importActionTemplates(_ seedData: SeedData, modelContext: ModelContext) async throws {
        for actionData in seedData.actions {
            // Check if template already exists
            let predicate = #Predicate<ActionTemplate> { template in
                template.id == actionData.id
            }
            let descriptor = FetchDescriptor<ActionTemplate>(predicate: predicate)
            let existing = try modelContext.fetch(descriptor).first
            
            if let existing = existing {
                // Update if content version is newer
                if actionData.contentVersion > existing.contentVersion {
                    updateActionTemplate(existing, with: actionData)
                    print("Updated action template: \(actionData.id)")
                }
            } else {
                // Create new template
                let template = createActionTemplate(from: actionData)
                modelContext.insert(template)
                print("Created action template: \(actionData.id)")
            }
        }
        
        try modelContext.save()
    }
    
    private static func updateActionTemplate(_ template: ActionTemplate, with data: ActionData) {
        template.focusId = data.focusId
        template.title = data.title
        template.whyLine = data.whyLine
        template.tags = data.tags
        template.difficulty = data.difficulty
        template.contraindications = data.contraindications
        template.contentVersion = data.contentVersion
        
        // Update variants
        template.variants = data.variants.map { variantData in
            TemplateVariant(durationMinutes: variantData.durationMinutes, steps: variantData.steps)
        }
    }
    
    private static func createActionTemplate(from data: VariantData) -> ActionTemplate {
        let template = ActionTemplate(
            id: data.id,
            focusId: data.focusId,
            title: data.title,
            whyLine: data.whyLine,
            tags: data.tags,
            difficulty: data.difficulty,
            variants: data.variants.map { variantData in
                TemplateVariant(durationMinutes: variantData.durationMinutes, steps: variantData.steps)
            },
            contraindications: data.contraindications,
            contentVersion: data.contentVersion
        )
        return template
    }
    
    private static func createDefaultFocusAreas(modelContext: ModelContext) async throws {
        // Check if focus areas already exist
        let descriptor = FetchDescriptor<FocusArea>()
        let existingFocuses = try modelContext.fetch(descriptor)
        
        if existingFocuses.isEmpty {
            // Create Independence focus
            let independenceBlocks = [
                BuildingBlock(type: "microSkill", title: "Try first, ask for help after", desc: "Wait time invites initiative", tags: ["initiative"]),
                BuildingBlock(type: "ritual", title: "Weekend outfit choice", desc: "Regular practice builds confidence", tags: ["choice_making"]),
                BuildingBlock(type: "support", title: "Lay out two options", desc: "Structure without control", tags: ["choice_making"])
            ]
            
            let independenceFocus = FocusArea(
                id: "independence",
                name: "Independence",
                active: true,
                startedAt: Date.now,
                buildingBlocks: independenceBlocks,
                pinnedMicroSkillTitles: []
            )
            modelContext.insert(independenceFocus)
            
            // Create Emotion Skills focus
            let emotionBlocks = [
                BuildingBlock(type: "microSkill", title: "Name 3 feelings", desc: "Build emotional vocabulary", tags: ["labeling"]),
                BuildingBlock(type: "ritual", title: "Feelings check‑in at dinner", desc: "Regular practice in calm moments", tags: ["labeling"]),
                BuildingBlock(type: "support", title: "Visual chart", desc: "Reference tool for naming feelings", tags: ["labeling"])
            ]
            
            let emotionFocus = FocusArea(
                id: "emotion_skills",
                name: "Emotion Skills",
                active: true,
                startedAt: Date.now,
                buildingBlocks: emotionBlocks,
                pinnedMicroSkillTitles: []
            )
            modelContext.insert(emotionFocus)
            
            try modelContext.save()
            print("Created default focus areas")
        }
    }
}

// MARK: - Seed Data Models

struct SeedData: Codable {
    let contentVersion: Int
    let actions: [VariantData]
}

struct VariantData: Codable {
    let id: String
    let focusId: String
    let title: String
    let whyLine: String
    let tags: [String]
    let difficulty: Int
    let variants: [VariantInfo]
    let contraindications: [String]
    let contentVersion: Int
}

struct VariantInfo: Codable {
    let durationMinutes: Int
    let steps: [String]
}

// Alias for the action data structure
typealias ActionData = VariantData
