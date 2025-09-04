import Foundation

enum MockContent {
    
    // MARK: - Today Suggestions
    
    static let independenceToday = Suggestion(
        focus: FocusArea(id: "independence", name: "Independence"),
        headline: "You pick the plan; I'm backup",
        actions: [
            ActionTemplate(
                id: "A-IND-CHOICE-001",
                focusId: "independence",
                title: "Child chooses between two outfits",
                whyLine: "Choice builds autonomy without chaos",
                variants: [
                    TemplateVariant(durationMinutes: 5, steps: ["Lay out two outfits", "Let them pick"]),
                    TemplateVariant(durationMinutes: 10, steps: ["Two outfits", "They dress first", "Assist only if asked"]),
                    TemplateVariant(durationMinutes: 20, steps: ["Two outfits", "They dress", "Add simple accessory choice"])
                ]
            ),
            ActionTemplate(
                id: "A-IND-TRY-FIRST-001",
                focusId: "independence",
                title: "Try first, ask for help after",
                whyLine: "Wait time invites initiative",
                variants: [
                    TemplateVariant(durationMinutes: 5, steps: ["Set a 30s wait before helping"]),
                    TemplateVariant(durationMinutes: 10, steps: ["Set 60s wait", "Name one effort you noticed"]),
                    TemplateVariant(durationMinutes: 20, steps: ["Try a 2‑step chore", "You're backup"])
                ]
            )
        ],
        explainWhy: "Because evenings worked and you picked 5‑min options, here are two 5‑min choices."
    )
    
    static let emotionToday = Suggestion(
        focus: FocusArea(id: "emotion_skills", name: "Emotion Skills"),
        headline: "Name your feeling, invite theirs",
        actions: [
            ActionTemplate(
                id: "A-EMO-LABEL-001",
                focusId: "emotion_skills",
                title: "I feel… because…",
                whyLine: "Models language and safety",
                variants: [
                    TemplateVariant(durationMinutes: 5, steps: ["You model 'I feel… because…'", "Invite theirs"]),
                    TemplateVariant(durationMinutes: 10, steps: ["Use feelings chart", "Name 1 body clue"]),
                    TemplateVariant(durationMinutes: 20, steps: ["Read short story", "Guess character's feeling together"])
                ]
            )
        ],
        explainWhy: "Because after‑school works best, we're suggesting after‑school options."
    )
    
    // MARK: - Weekly Summaries
    
    static let independenceWeek = WeeklySummary(
        id: "independence-week-1",
        weekStart: Date.now,
        focusId: "independence",
        winText: "Chose shirt twice without stress",
        hardText: "Timer felt rushed on school mornings",
        suggestedTweak: "scale_down"
    )
    
    static let emotionWeek = WeeklySummary(
        id: "emotion-week-1",
        weekStart: Date.now,
        focusId: "emotion_skills",
        winText: "Child named 'frustrated' twice",
        hardText: "Still hard to name feelings when upset",
        suggestedTweak: "keep"
    )
    
    // MARK: - Monthly Plans
    
    static let independenceMonthly = [
        BuildingBlock(
            type: "microSkill",
            title: "Try first, ask for help after",
            desc: "Wait time invites initiative"
        ),
        BuildingBlock(
            type: "ritual",
            title: "Weekend outfit choice",
            desc: "Regular practice builds confidence"
        ),
        BuildingBlock(
            type: "support",
            title: "Lay out two options",
            desc: "Structure without control"
        )
    ]
    
    static let emotionMonthly = [
        BuildingBlock(
            type: "microSkill",
            title: "Name 3 feelings",
            desc: "Build emotional vocabulary"
        ),
        BuildingBlock(
            type: "ritual",
            title: "Feelings check‑in at dinner",
            desc: "Regular practice in calm moments"
        ),
        BuildingBlock(
            type: "support",
            title: "Visual chart",
            desc: "Reference tool for naming feelings"
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
        switch focus.id {
        case "independence":
            return independenceToday
        case "emotion_skills":
            return emotionToday
        default:
            return independenceToday
        }
    }
    
    static func weeklySummary(for focus: FocusArea) -> WeeklySummary {
        switch focus.id {
        case "independence":
            return independenceWeek
        case "emotion_skills":
            return emotionWeek
        default:
            return independenceWeek
        }
    }
    
    static func monthlyPlan(for focus: FocusArea) -> [BuildingBlock] {
        switch focus.id {
        case "independence":
            return independenceMonthly
        case "emotion_skills":
            return emotionMonthly
        default:
            return independenceMonthly
        }
    }
    
    static func seasonSummary(for focus: FocusArea) -> SeasonSummary {
        switch focus.id {
        case "independence":
            return independenceSeason
        case "emotion_skills":
            return emotionSeason
        default:
            return independenceSeason
        }
    }
}