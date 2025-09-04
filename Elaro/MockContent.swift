import Foundation

enum MockContent {
    
    // MARK: - Today Suggestions
    
    static let independenceToday = Suggestion(
        focus: .independence,
        headline: "You pick the plan; I'm backup",
        actions: [
            ActionTemplate(
                title: "Child chooses between two outfits",
                whyLine: "Choice builds autonomy without chaos",
                variants: [
                    ActionVariant(durationMinutes: 5, steps: ["Lay out two outfits", "Let them pick"]),
                    ActionVariant(durationMinutes: 10, steps: ["Two outfits", "They dress first", "Assist only if asked"]),
                    ActionVariant(durationMinutes: 20, steps: ["Two outfits", "They dress", "Add simple accessory choice"])
                ]
            ),
            ActionTemplate(
                title: "Try first, ask for help after",
                whyLine: "Wait time invites initiative",
                variants: [
                    ActionVariant(durationMinutes: 5, steps: ["Set a 30s wait before helping"]),
                    ActionVariant(durationMinutes: 10, steps: ["Set 60s wait", "Name one effort you noticed"]),
                    ActionVariant(durationMinutes: 20, steps: ["Try a 2‑step chore", "You're backup"])
                ]
            )
        ],
        explainWhy: "Because evenings worked and you picked 5‑min options, here are two 5‑min choices."
    )
    
    static let emotionToday = Suggestion(
        focus: .emotionSkills,
        headline: "Name your feeling, invite theirs",
        actions: [
            ActionTemplate(
                title: "I feel… because…",
                whyLine: "Models language and safety",
                variants: [
                    ActionVariant(durationMinutes: 5, steps: ["You model 'I feel… because…'", "Invite theirs"]),
                    ActionVariant(durationMinutes: 10, steps: ["Use feelings chart", "Name 1 body clue"]),
                    ActionVariant(durationMinutes: 20, steps: ["Read short story", "Guess character's feeling together"])
                ]
            )
        ],
        explainWhy: "Because after‑school works best, we're suggesting after‑school options."
    )
    
    // MARK: - Weekly Summaries
    
    static let independenceWeek = WeeklySummary(
        winText: "Chose shirt twice without stress",
        hardText: "Timer felt rushed on school mornings",
        suggestedTweak: .scaleDown
    )
    
    static let emotionWeek = WeeklySummary(
        winText: "Child named 'frustrated' twice",
        hardText: "Still hard to name feelings when upset",
        suggestedTweak: .keep
    )
    
    // MARK: - Monthly Plans
    
    static let independenceMonthly = [
        BuildingBlock(
            type: .microSkill,
            title: "Try first, ask for help after",
            description: "Wait time invites initiative"
        ),
        BuildingBlock(
            type: .ritual,
            title: "Weekend outfit choice",
            description: "Regular practice builds confidence"
        ),
        BuildingBlock(
            type: .support,
            title: "Lay out two options",
            description: "Structure without control"
        )
    ]
    
    static let emotionMonthly = [
        BuildingBlock(
            type: .microSkill,
            title: "Name 3 feelings",
            description: "Build emotional vocabulary"
        ),
        BuildingBlock(
            type: .ritual,
            title: "Feelings check‑in at dinner",
            description: "Regular practice in calm moments"
        ),
        BuildingBlock(
            type: .support,
            title: "Visual chart",
            description: "Reference tool for naming feelings"
        )
    ]
    
    // MARK: - Season Summaries
    
    static let independenceSeason = SeasonSummary(
        themeEvolution: "Independence → Self‑management",
        rungs: ["Initiates choice", "Manages simple sequences"],
        storyPrompt: "What surprised you this season?",
        nextSeasonPreview: "nudge toward Self‑management (prep backpack checklist)"
    )
    
    static let emotionSeason = SeasonSummary(
        themeEvolution: "Emotion Skills → Repair scripts",
        rungs: ["Names basic feelings", "Uses feeling words when calm"],
        storyPrompt: "What surprised you this season?",
        nextSeasonPreview: "keep Emotion Skills; add Repair scripts next season"
    )
    
    // MARK: - Helper Methods
    
    static func suggestion(for focus: FocusArea) -> Suggestion {
        switch focus {
        case .independence:
            return independenceToday
        case .emotionSkills:
            return emotionToday
        }
    }
    
    static func weeklySummary(for focus: FocusArea) -> WeeklySummary {
        switch focus {
        case .independence:
            return independenceWeek
        case .emotionSkills:
            return emotionWeek
        }
    }
    
    static func monthlyPlan(for focus: FocusArea) -> [BuildingBlock] {
        switch focus {
        case .independence:
            return independenceMonthly
        case .emotionSkills:
            return emotionMonthly
        }
    }
    
    static func seasonSummary(for focus: FocusArea) -> SeasonSummary {
        switch focus {
        case .independence:
            return independenceSeason
        case .emotionSkills:
            return emotionSeason
        }
    }
}