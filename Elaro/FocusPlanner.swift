import Foundation
import SwiftData

@MainActor
final class FocusPlanner {
    private let store: FocusStore
    
    init(store: FocusStore) {
        self.store = store
    }
    
    // MARK: - Building Block Management
    
    func getBuildingBlocks(for focusId: String) -> [BuildingBlock] {
        guard let focus = store.focus(by: focusId) else {
            return getDefaultBuildingBlocks(for: focusId)
        }
        
        return focus.buildingBlocks
    }
    
    func updateBuildingBlocks(for focusId: String, blocks: [BuildingBlock]) {
        store.updateBuildingBlocks(for: focusId, blocks: blocks)
    }
    
    func updateBuildingBlock(for focusId: String, at index: Int, block: BuildingBlock) {
        var blocks = getBuildingBlocks(for: focusId)
        guard index < blocks.count else { return }
        
        blocks[index] = block
        updateBuildingBlocks(for: focusId, blocks: blocks)
    }
    
    // MARK: - Pin Management
    
    func getPinnedMicroSkills(for focusId: String) -> [String] {
        guard let focus = store.focus(by: focusId) else {
            return []
        }
        
        return focus.pinnedMicroSkillTitles
    }
    
    func updatePinnedMicroSkills(for focusId: String, pinnedTitles: [String]) {
        store.updatePinnedMicroSkills(for: focusId, pinnedTitles: pinnedTitles)
    }
    
    func togglePin(for focusId: String, title: String) {
        var pinnedTitles = getPinnedMicroSkills(for: focusId)
        
        if pinnedTitles.contains(title) {
            pinnedTitles.removeAll { $0 == title }
        } else {
            pinnedTitles.append(title)
        }
        
        updatePinnedMicroSkills(for: focusId, pinnedTitles: pinnedTitles)
    }
    
    // MARK: - Building Block Suggestions
    
    func suggestBuildingBlocks(for focusId: String) -> [BuildingBlock] {
        let actions = store.actions(for: focusId)
        
        // Analyze action tags to suggest building blocks
        var tagCounts: [String: Int] = [:]
        for action in actions {
            for tag in action.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        // Get top tags
        let topTags = tagCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        // Create building blocks based on top tags
        var blocks: [BuildingBlock] = []
        
        // Micro-skill (most common tag)
        if let topTag = topTags.first {
            blocks.append(BuildingBlock(
                type: "microSkill",
                title: generateMicroSkillTitle(for: topTag),
                desc: generateMicroSkillDescription(for: topTag),
                tags: [topTag]
            ))
        }
        
        // Ritual (second most common tag)
        if topTags.count > 1 {
            blocks.append(BuildingBlock(
                type: "ritual",
                title: generateRitualTitle(for: topTags[1]),
                desc: generateRitualDescription(for: topTags[1]),
                tags: [topTags[1]]
            ))
        }
        
        // Support (third most common tag or generic)
        if topTags.count > 2 {
            blocks.append(BuildingBlock(
                type: "support",
                title: generateSupportTitle(for: topTags[2]),
                desc: generateSupportDescription(for: topTags[2]),
                tags: [topTags[2]]
            ))
        } else {
            blocks.append(BuildingBlock(
                type: "support",
                title: "Create supportive environment",
                desc: "Set up the space and tools needed for success",
                tags: ["support"]
            ))
        }
        
        return blocks
    }
    
    // MARK: - Default Building Blocks
    
    private func getDefaultBuildingBlocks(for focusId: String) -> [BuildingBlock] {
        switch focusId {
        case "independence":
            return [
                BuildingBlock(type: "microSkill", title: "Try first, ask for help after", desc: "Wait time invites initiative", tags: ["initiative"]),
                BuildingBlock(type: "ritual", title: "Weekend outfit choice", desc: "Regular practice builds confidence", tags: ["choice_making"]),
                BuildingBlock(type: "support", title: "Lay out two options", desc: "Structure without control", tags: ["choice_making"])
            ]
        case "emotion_skills":
            return [
                BuildingBlock(type: "microSkill", title: "Name 3 feelings", desc: "Build emotional vocabulary", tags: ["labeling"]),
                BuildingBlock(type: "ritual", title: "Feelings check‑in at dinner", desc: "Regular practice in calm moments", tags: ["labeling"]),
                BuildingBlock(type: "support", title: "Visual chart", desc: "Reference tool for naming feelings", tags: ["labeling"])
            ]
        default:
            return [
                BuildingBlock(type: "microSkill", title: "Practice core skill", desc: "Build foundational competence", tags: []),
                BuildingBlock(type: "ritual", title: "Regular practice", desc: "Consistent daily routine", tags: []),
                BuildingBlock(type: "support", title: "Supportive environment", desc: "Set up for success", tags: [])
            ]
        }
    }
    
    // MARK: - Title and Description Generation
    
    private func generateMicroSkillTitle(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Make simple choices"
        case "initiative":
            return "Try first, ask for help after"
        case "sequencing":
            return "Follow 2-step sequences"
        case "labeling":
            return "Name feelings"
        case "co_regulation":
            return "Co-regulate with breathing"
        case "repair":
            return "Simple repair script"
        default:
            return "Practice \(tag.replacingOccurrences(of: "_", with: " "))"
        }
    }
    
    private func generateMicroSkillDescription(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Build autonomy through structured choices"
        case "initiative":
            return "Wait time invites problem-solving"
        case "sequencing":
            return "Sequential thinking builds executive function"
        case "labeling":
            return "Emotional vocabulary supports regulation"
        case "co_regulation":
            return "Shared calm creates safety"
        case "repair":
            return "Repair builds trust and resilience"
        default:
            return "Develop core competence in \(tag.replacingOccurrences(of: "_", with: " "))"
        }
    }
    
    private func generateRitualTitle(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Daily choice ritual"
        case "initiative":
            return "Morning independence routine"
        case "sequencing":
            return "Evening sequence practice"
        case "labeling":
            return "Feelings check-in at dinner"
        case "co_regulation":
            return "Calm connection time"
        case "repair":
            return "Repair and reconnect ritual"
        default:
            return "Regular \(tag.replacingOccurrences(of: "_", with: " ")) practice"
        }
    }
    
    private func generateRitualDescription(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Regular practice builds confidence"
        case "initiative":
            return "Consistent routine supports independence"
        case "sequencing":
            return "Daily practice strengthens executive function"
        case "labeling":
            return "Regular practice in calm moments"
        case "co_regulation":
            return "Scheduled connection time"
        case "repair":
            return "Regular repair practice"
        default:
            return "Consistent practice builds competence"
        }
    }
    
    private func generateSupportTitle(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Choice-friendly environment"
        case "initiative":
            return "Independence support tools"
        case "sequencing":
            return "Visual sequence supports"
        case "labeling":
            return "Feelings chart and tools"
        case "co_regulation":
            return "Calm space setup"
        case "repair":
            return "Repair conversation starters"
        default:
            return "Supportive \(tag.replacingOccurrences(of: "_", with: " ")) environment"
        }
    }
    
    private func generateSupportDescription(for tag: String) -> String {
        switch tag {
        case "choice_making":
            return "Structure without control"
        case "initiative":
            return "Tools that invite independence"
        case "sequencing":
            return "Visual aids for sequence learning"
        case "labeling":
            return "Reference tools for naming feelings"
        case "co_regulation":
            return "Calm, safe space for connection"
        case "repair":
            return "Conversation starters for repair"
        default:
            return "Environmental support for \(tag.replacingOccurrences(of: "_", with: " "))"
        }
    }
}
