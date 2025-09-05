import SwiftData
import Foundation

@MainActor
func seedIfNeeded(modelContext: ModelContext) async {
    // Check if we already have focus areas
    let focusFetch = FetchDescriptor<FocusArea>()
    let hasFocusAreas = ((try? modelContext.fetch(focusFetch))?.isEmpty ?? true) == false
    
    if !hasFocusAreas {
        // Create default focus areas
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
    }
    
    try? modelContext.save()
}
