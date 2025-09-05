import Foundation

@MainActor
struct WeeklyAdjuster {
    private let store: FocusStore
    private let signals: SignalsEngine
    
    init(store: FocusStore) {
        self.store = store
        self.signals = SignalsEngine(store: store)
    }
    
    // MARK: - Weekly Analysis
    
    func analyzeWeek(for focusId: String, weekStart: Date) -> WeeklyAnalysis {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        let range = DateInterval(start: weekStart, end: weekEnd)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let completedInstances = instances.filter { $0.status == "done" }
        let totalInstances = instances.count
        
        let completionRate = totalInstances > 0 ? Double(completedInstances.count) / Double(totalInstances) : 0.0
        let frictionIndex = signals.computeFrictionIndex(focusId: focusId, days: 7)
        
        // Generate win text
        let winText = generateWinText(instances: completedInstances)
        
        // Generate hard text
        let hardText = generateHardText(instances: instances, frictionIndex: frictionIndex)
        
        // Determine suggested tweak
        let suggestedTweak = determineSuggestedTweak(completionRate: completionRate, frictionIndex: frictionIndex)
        
        // Generate rationale
        let rationale = generateRationale(completionRate: completionRate, frictionIndex: frictionIndex, suggestedTweak: suggestedTweak)
        
        return WeeklyAnalysis(
            focusId: focusId,
            weekStart: weekStart,
            completionRate: completionRate,
            frictionIndex: frictionIndex,
            winText: winText,
            hardText: hardText,
            suggestedTweak: suggestedTweak,
            rationale: rationale
        )
    }
    
    // MARK: - Tweak Decision Logic
    
    private func determineSuggestedTweak(completionRate: Double, frictionIndex: Double) -> TweakDecision {
        if completionRate >= 0.7 && frictionIndex <= 0.3 {
            return .scaleUp
        } else if completionRate <= 0.3 || frictionIndex > 0.4 {
            return .scaleDown
        } else {
            return .keep
        }
    }
    
    // MARK: - Text Generation
    
    private func generateWinText(instances: [ActionInstance]) -> String {
        guard !instances.isEmpty else {
            return "No completed actions this week"
        }
        
        // Count successful completions by template
        var templateCounts: [String: Int] = [:]
        for instance in instances {
            templateCounts[instance.templateId, default: 0] += 1
        }
        
        // Find most successful template
        let mostSuccessful = templateCounts.max { $0.value < $1.value }
        
        if let templateId = mostSuccessful?.key,
           let template = store.allActions().first(where: { $0.id == templateId }) {
            let count = mostSuccessful?.value ?? 0
            if count > 1 {
                return "Completed '\(template.title)' \(count) times"
            } else {
                return "Successfully completed '\(template.title)'"
            }
        }
        
        return "Completed \(instances.count) action\(instances.count == 1 ? "" : "s")"
    }
    
    private func generateHardText(instances: [ActionInstance], frictionIndex: Double) -> String {
        let hardInstances = instances.filter { $0.feltDifficulty == "hard" }
        let stressInstances = instances.filter { instance in
            guard let note = instance.note?.lowercased() else { return false }
            let stressKeywords = ["overwhelmed", "meltdown", "tears", "frustrated", "angry", "upset"]
            return stressKeywords.contains { note.contains($0) }
        }
        
        if frictionIndex > 0.4 {
            return "Several activities felt challenging this week"
        } else if !hardInstances.isEmpty {
            return "Some activities felt difficult"
        } else if !stressInstances.isEmpty {
            return "Noticed some stress during activities"
        } else {
            return "Activities felt manageable overall"
        }
    }
    
    private func generateRationale(completionRate: Double, frictionIndex: Double, suggestedTweak: TweakDecision) -> String {
        switch suggestedTweak {
        case .scaleUp:
            return "You're doing great! With \(Int(completionRate * 100))% completion and low friction, you're ready for slightly more challenging activities."
        case .scaleDown:
            if completionRate <= 0.3 {
                return "With \(Int(completionRate * 100))% completion, let's make activities smaller and more manageable."
            } else {
                return "The high friction suggests we should simplify activities to reduce stress."
            }
        case .keep:
            return "Your current pace seems right - \(Int(completionRate * 100))% completion with manageable difficulty."
        }
    }
    
    // MARK: - Apply Tweak
    
    func applyTweak(_ tweak: TweakDecision, for focusId: String) {
        // Create weekly summary
        let weekStart = getCurrentWeekStart()
        let analysis = analyzeWeek(for: focusId, weekStart: weekStart)
        
        let summary = WeeklySummary(
            id: "\(focusId)-\(Int(weekStart.timeIntervalSince1970))",
            weekStart: weekStart,
            focusId: focusId,
            winText: analysis.winText,
            hardText: analysis.hardText,
            suggestedTweak: tweak.rawValue
        )
        
        store.save(summary: summary)
        
        // Apply tweak to focus area (could influence future recommendations)
        // For now, we'll just log the decision
        print("Applied tweak \(tweak.rawValue) for focus \(focusId)")
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentWeekStart() -> Date {
        let calendar = Calendar.current
        let now = Date.now
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.year, from: now)
        
        var components = DateComponents()
        components.weekOfYear = weekOfYear
        components.yearForWeekOfYear = year
        components.weekday = calendar.firstWeekday
        
        return calendar.date(from: components) ?? now
    }
}

// MARK: - Supporting Types

struct WeeklyAnalysis {
    let focusId: String
    let weekStart: Date
    let completionRate: Double
    let frictionIndex: Double
    let winText: String
    let hardText: String
    let suggestedTweak: TweakDecision
    let rationale: String
}

enum TweakDecision: String, CaseIterable {
    case keep = "keep"
    case scaleDown = "scale_down"
    case scaleUp = "scale_up"
    
    var displayName: String {
        switch self {
        case .keep:
            return "Keep"
        case .scaleDown:
            return "Scale down"
        case .scaleUp:
            return "Scale up"
        }
    }
}
