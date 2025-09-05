import Foundation
import SwiftData

// MARK: - Decoding structs (tolerant)
private struct SeedFile: Decodable {
    let contentVersion: Int?       // optional file-level version
    let actions: [SeedAction]
}
private struct SeedAction: Decodable {
    let id: String
    let focusId: String            // "independence" | "emotion_skills"
    let title: String
    let whyLine: String
    let tags: [String]
    let difficulty: Int
    let variants: [SeedVariant]
    let contraindications: [String]?
    let contentVersion: Int?       // optional action-level override
}
private struct SeedVariant: Decodable {
    let durationMinutes: Int
    let steps: [String]
}

@MainActor
enum SeedImporter {
    static func runIfNeeded(context: ModelContext) {
        // Gate by a simple key so we don't re-import on every launch
        let key = "seed.actions.v1.ran"
        if UserDefaults.standard.bool(forKey: key) { return }

        do {
            try run(context: context)
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            print("Failed to load seed data:", error.localizedDescription)
        }
    }

    static func run(context: ModelContext) throws {
        guard let url = Bundle.main.url(forResource: "actions_seed", withExtension: "json") else {
            throw NSError(domain: "SeedImporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "actions_seed.json not found in bundle"])
        }
        let data = try Data(contentsOf: url)
        let file = try JSONDecoder().decode(SeedFile.self, from: data)

        // Ensure the 2 default FocusAreas exist
        upsertFocusIfMissing(id: "independence", name: "Independence", context: context)
        upsertFocusIfMissing(id: "emotion_skills", name: "Emotion Skills", context: context)

        let fileVersion = file.contentVersion ?? 1

        for a in file.actions {
            let version = a.contentVersion ?? fileVersion
            try upsertAction(from: a, contentVersion: version, context: context)
        }
        try context.save()

        #if DEBUG
        // sanity log: actions by focus
        let all = try context.fetch(FetchDescriptor<ActionTemplate>())
        let grouped = Dictionary(grouping: all, by: { $0.focusId }).mapValues { $0.count }
        print("[Seed] actions by focus:", grouped)
        #endif
    }

    private static func upsertFocusIfMissing(id: String, name: String, context: ModelContext) {
        let fd = FetchDescriptor<FocusArea>(predicate: #Predicate { $0.id == id })
        if let existing = try? context.fetch(fd).first, existing != nil { return }
        let f = FocusArea(id: id, name: name, active: true, startedAt: Date(),
                          buildingBlocks: [], pinnedMicroSkillTitles: [], seasonNote: nil)
        context.insert(f)
    }

    private static func upsertAction(from a: SeedAction, contentVersion: Int, context: ModelContext) throws {
        let actionId = a.id
        let fd = FetchDescriptor<ActionTemplate>(predicate: #Predicate<ActionTemplate> { template in
            template.id == actionId
        })
        if let existing = try context.fetch(fd).first {
            // update only if newer contentVersion
            if existing.contentVersion < contentVersion {
                existing.focusId = a.focusId
                existing.title = a.title
                existing.whyLine = a.whyLine
                existing.tags = a.tags
                existing.difficulty = a.difficulty
                existing.contraindications = a.contraindications ?? []
                existing.variants = a.variants.map { TemplateVariant(durationMinutes: $0.durationMinutes, steps: $0.steps) }
                existing.contentVersion = contentVersion
            }
        } else {
            let tpl = ActionTemplate(
                id: a.id,
                focusId: a.focusId,
                title: a.title,
                whyLine: a.whyLine,
                tags: a.tags,
                difficulty: a.difficulty,
                variants: a.variants.map { TemplateVariant(durationMinutes: $0.durationMinutes, steps: $0.steps) },
                contraindications: a.contraindications ?? [],
                contentVersion: contentVersion
            )
            context.insert(tpl)
        }
    }
}