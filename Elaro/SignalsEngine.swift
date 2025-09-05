import Foundation

@MainActor
struct SignalsEngine {
    private let store: FocusStore
    
    init(store: FocusStore) {
        self.store = store
    }
    
    // MARK: - Success Rate by Tag
    
    func computeSuccessRateByTag(focusId: String, days: Int = 7) -> [String: Double] {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let actions = store.actions(for: focusId)
        
        var tagStats: [String: (completed: Int, total: Int)] = [:]
        
        // Count completed instances by tag
        for instance in instances {
            guard let template = actions.first(where: { $0.id == instance.templateId }),
                  instance.status == "done" else { continue }
            
            for tag in template.tags {
                tagStats[tag, default: (0, 0)].completed += 1
            }
        }
        
        // Count total instances by tag (approximate by assuming all shown actions were attempted)
        for instance in instances {
            guard let template = actions.first(where: { $0.id == instance.templateId }) else { continue }
            
            for tag in template.tags {
                tagStats[tag, default: (0, 0)].total += 1
            }
        }
        
        // Calculate success rates
        var successRates: [String: Double] = [:]
        for (tag, stats) in tagStats {
            if stats.total > 0 {
                successRates[tag] = Double(stats.completed) / Double(stats.total)
            } else {
                successRates[tag] = 0.0
            }
        }
        
        return successRates
    }
    
    // MARK: - Time of Day Heatmap
    
    func computeTimeOfDayHeatmap(days: Int = 14) -> [Int: Double] {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range)
        let completedInstances = instances.filter { $0.status == "done" }
        
        var hourCounts: [Int: Int] = [:]
        
        for instance in completedInstances {
            let hour = Calendar.current.component(.hour, from: instance.date)
            hourCounts[hour, default: 0] += 1
        }
        
        // Normalize to percentages
        let totalCompleted = completedInstances.count
        var heatmap: [Int: Double] = [:]
        
        for hour in 0..<24 {
            let count = hourCounts[hour] ?? 0
            heatmap[hour] = totalCompleted > 0 ? Double(count) / Double(totalCompleted) : 0.0
        }
        
        return heatmap
    }
    
    // MARK: - Bandwidth Preference
    
    func computeBandwidthPreference(focusId: String, days: Int = 14) -> Int {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let completedInstances = instances.filter { $0.status == "done" }
        
        var durationCounts: [Int: Int] = [:]
        
        for instance in completedInstances {
            durationCounts[instance.variantDuration, default: 0] += 1
        }
        
        // Return the most common duration (mode)
        let mostCommon = durationCounts.max { $0.value < $1.value }
        return mostCommon?.key ?? 10 // Default to 10 minutes
    }
    
    // MARK: - Novelty Tolerance
    
    func computeNoveltyTolerance(focusId: String, days: Int = 14) -> String {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let completedInstances = instances.filter { $0.status == "done" }
        
        // Count unique templates completed
        let uniqueTemplates = Set(completedInstances.map { $0.templateId })
        let totalCompleted = completedInstances.count
        
        if totalCompleted == 0 {
            return "med" // Default to medium
        }
        
        let noveltyRatio = Double(uniqueTemplates.count) / Double(totalCompleted)
        
        if noveltyRatio >= 0.7 {
            return "high"
        } else if noveltyRatio >= 0.4 {
            return "med"
        } else {
            return "low"
        }
    }
    
    // MARK: - Friction Index
    
    func computeFrictionIndex(focusId: String, days: Int = 7) -> Double {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        
        var frictionCount = 0
        let stressKeywords = ["overwhelmed", "meltdown", "tears", "frustrated", "angry", "upset"]
        
        for instance in instances {
            // Count "hard" difficulty
            if instance.feltDifficulty == "hard" {
                frictionCount += 1
            }
            
            // Count stress keywords in notes
            if let note = instance.note?.lowercased() {
                for keyword in stressKeywords {
                    if note.contains(keyword) {
                        frictionCount += 1
                        break // Only count once per instance
                    }
                }
            }
        }
        
        let totalInstances = instances.count
        return totalInstances > 0 ? Double(frictionCount) / Double(totalInstances) : 0.0
    }
    
    // MARK: - Streak Momentum
    
    func computeStreakMomentum(focusId: String, days: Int = 7) -> Double {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let completedInstances = instances.filter { $0.status == "done" }
        
        // Calculate completion rate over the period
        let totalInstances = instances.count
        return totalInstances > 0 ? Double(completedInstances.count) / Double(totalInstances) : 0.0
    }
    
    // MARK: - Peak Hours
    
    func computePeakHours(days: Int = 14) -> [Int] {
        let heatmap = computeTimeOfDayHeatmap(days: days)
        let sortedHours = heatmap.sorted { $0.value > $1.value }
        return Array(sortedHours.prefix(3).map { $0.key })
    }
    
    // MARK: - Recent Performance
    
    func computeRecentPerformance(focusId: String, days: Int = 3) -> Double {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let range = DateInterval(start: startDate, end: endDate)
        
        let instances = store.actionInstances(in: range, focusId: focusId)
        let completedInstances = instances.filter { $0.status == "done" }
        
        let totalInstances = instances.count
        return totalInstances > 0 ? Double(completedInstances.count) / Double(totalInstances) : 0.0
    }
}
