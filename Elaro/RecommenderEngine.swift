import Foundation

struct RecommenderEngine {
    private let store: FocusStore
    private let signals: SignalsEngine
    
    init(store: FocusStore) {
        self.store = store
        self.signals = SignalsEngine(store: store)
    }
    
    // MARK: - Main Recommendation Method
    
    func rank(for focusId: String, day: Date) -> [Suggestion] {
        let actions = store.actions(for: focusId)
        guard let focus = store.focus(by: focusId) else {
            return []
        }
        
        // Filter out contraindicated actions
        let filteredActions = filterContraindicatedActions(actions, focusId: focusId)
        
        // Score each action
        var scoredActions: [(ActionTemplate, Double)] = []
        
        for action in filteredActions {
            let score = calculateScore(for: action, focus: focus, day: day)
            scoredActions.append((action, score))
        }
        
        // Sort by score and take top 2-3
        scoredActions.sort { $0.1 > $1.1 }
        let topActions = Array(scoredActions.prefix(3))
        
        // Create suggestions
        var suggestions: [Suggestion] = []
        
        let explainWhy = buildExplainWhy(
            actions: topActions.map { $0.action },
            successRates: successRates,
            bandwidthPreference: bandwidthPreference,
            timeOfDayHeatmap: timeOfDayHeatmap
        )
        
        let suggestion = Suggestion(
            focus: FocusArea(id: focusId, name: focusId.capitalized),
            headline: "Try this today for \(focusId.capitalized)",
            actions: topActions.map { $0.action },
            explainWhy: explainWhy
        )
        
        return [suggestion]
    }
    
    // MARK: - Scoring Algorithm
    
    private func calculateScore(for action: ActionTemplate, focus: FocusArea, day: Date) -> Double {
        let focusMatch = calculateFocusMatch(action: action, focus: focus)
        let successProbability = calculateSuccessProbability(action: action, focusId: focus.id)
        let bandwidthFit = calculateBandwidthFit(action: action, focusId: focus.id)
        let timeOfDayFit = calculateTimeOfDayFit(action: action, day: day)
        let noveltyBoost = calculateNoveltyBoost(action: action, focusId: focus.id)
        let streakMomentum = calculateStreakMomentum(focusId: focus.id)
        let frictionRisk = calculateFrictionRisk(action: action, focusId: focus.id)
        
        let score = 0.35 * focusMatch +
                   0.20 * successProbability +
                   0.15 * bandwidthFit +
                   0.10 * timeOfDayFit +
                   0.10 * noveltyBoost +
                   0.10 * streakMomentum -
                   0.10 * frictionRisk
        
        return max(0.0, min(1.0, score)) // Clamp between 0 and 1
    }
    
    // MARK: - Score Components
    
    private func calculateFocusMatch(action: ActionTemplate, focus: FocusArea) -> Double {
        let focusTags = Set(focus.buildingBlocks.flatMap { $0.tags } + focus.pinnedMicroSkillTitles)
        let actionTags = Set(action.tags)
        
        let intersection = focusTags.intersection(actionTags)
        let union = focusTags.union(actionTags)
        
        return union.isEmpty ? 0.0 : Double(intersection.count) / Double(union.count)
    }
    
    private func calculateSuccessProbability(action: ActionTemplate, focusId: String) -> Double {
        let successRates = signals.computeSuccessRateByTag(focusId: focusId)
        
        // Average success rate for action's tags
        let actionTagRates = action.tags.compactMap { successRates[$0] }
        return actionTagRates.isEmpty ? 0.5 : actionTagRates.reduce(0, +) / Double(actionTagRates.count)
    }
    
    private func calculateBandwidthFit(action: ActionTemplate, focusId: String) -> Double {
        let preferredBandwidth = signals.computeBandwidthPreference(focusId: focusId)
        let actionDurations = action.variants.map { $0.durationMinutes }
        
        // Check if preferred duration is available
        return actionDurations.contains(preferredBandwidth) ? 1.0 : 0.5
    }
    
    private func calculateTimeOfDayFit(action: ActionTemplate, day: Date) -> Double {
        let currentHour = Calendar.current.component(.hour, from: day)
        let peakHours = signals.computePeakHours()
        
        // Boost if current hour is in peak hours
        return peakHours.contains(currentHour) ? 1.0 : 0.7
    }
    
    private func calculateNoveltyBoost(action: ActionTemplate, focusId: String) -> Double {
        let tolerance = signals.computeNoveltyTolerance(focusId: focusId)
        
        // Check if this action was recently used
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let recentInstances = store.actionInstances(in: range, focusId: focusId)
        let wasRecentlyUsed = recentInstances.contains { $0.templateId == action.id }
        
        switch tolerance {
        case "high":
            return wasRecentlyUsed ? 0.3 : 1.0 // Prefer new actions
        case "med":
            return wasRecentlyUsed ? 0.6 : 0.8 // Slight preference for new
        case "low":
            return wasRecentlyUsed ? 1.0 : 0.4 // Prefer familiar actions
        default:
            return 0.7
        }
    }
    
    private func calculateStreakMomentum(focusId: String) -> Double {
        return signals.computeStreakMomentum(focusId: focusId)
    }
    
    private func calculateFrictionRisk(action: ActionTemplate, focusId: String) -> Double {
        let frictionIndex = signals.computeFrictionIndex(focusId: focusId)
        
        // Higher difficulty actions have higher friction risk
        let difficultyRisk = Double(action.difficulty) / 5.0
        
        return (frictionIndex + difficultyRisk) / 2.0
    }
    
    // MARK: - Helper Methods
    
    private func filterContraindicatedActions(_ actions: [ActionTemplate], focusId: String) -> [ActionTemplate] {
        // Check for recent dysregulation indicators
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let recentInstances = store.actionInstances(in: range, focusId: focusId)
        let dysregulationKeywords = ["overwhelmed", "meltdown", "tears", "dysregulated"]
        
        let hasRecentDysregulation = recentInstances.contains { instance in
            guard let note = instance.note?.lowercased() else { return false }
            return dysregulationKeywords.contains { note.contains($0) }
        }
        
        if hasRecentDysregulation {
            return actions.filter { !$0.contraindications.contains("skip_if_dysregulated") }
        }
        
        return actions
    }
    
    private func selectBestVariant(for action: ActionTemplate) -> TemplateVariant {
        let preferredBandwidth = signals.computeBandwidthPreference(focusId: action.focusId)
        
        // Try to find preferred duration
        if let preferredVariant = action.variants.first(where: { $0.durationMinutes == preferredBandwidth }) {
            return preferredVariant
        }
        
        // Fall back to middle duration
        let sortedVariants = action.variants.sorted { $0.durationMinutes < $1.durationMinutes }
        return sortedVariants[sortedVariants.count / 2]
    }
    
    private func generateHeadline(for action: ActionTemplate, focus: FocusArea) -> String {
        let focusName = focus.name
        return "Try this today for \(focusName)"
    }
    
    private func generateExplainWhy(for action: ActionTemplate, focus: FocusArea, score: Double) -> String {
        let bandwidth = signals.computeBandwidthPreference(focusId: focus.id)
        let peakHours = signals.computePeakHours()
        let currentHour = Calendar.current.component(.hour, from: Date.now)
        
        var reasons: [String] = []
        
        // Add bandwidth reason
        reasons.append("you prefer \(bandwidth)-minute activities")
        
        // Add time reason
        if peakHours.contains(currentHour) {
            reasons.append("this time of day works well for you")
        }
        
        // Add focus alignment reason
        let focusTags = Set(focus.buildingBlocks.flatMap { $0.tags } + focus.pinnedMicroSkillTitles)
        let actionTags = Set(action.tags)
        let matchingTags = focusTags.intersection(actionTags)
        
        if !matchingTags.isEmpty {
            reasons.append("it aligns with your focus on \(matchingTags.joined(separator: " and "))")
        }
        
        return "Because \(reasons.joined(separator: " and ")), here's a suggestion for today."
    }
}
