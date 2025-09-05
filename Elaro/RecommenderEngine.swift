import Foundation
import SwiftData

struct RankedSuggestion: Identifiable {
    let id = UUID()
    let headline: String
    let actions: [ActionTemplate]        // 1–3 templates
    let chosenVariants: [Int: Int]       // templateIndex : durationMinutes
    let whySummary: String
}

@MainActor
final class RecommenderEngine {
    private let store: FocusStore
    private let signals: SignalsEngine
    private let explain: ExplainWhyBuilder
    
    init(store: FocusStore, signals: SignalsEngine, explain: ExplainWhyBuilder) {
        self.store = store
        self.signals = signals
        self.explain = explain
    }
    
    // MARK: - Main Recommendation Method
    
    func rank(for focusId: String, day: Date = .now) -> [RankedSuggestion] {
        let candidates = store.actions(for: focusId)
        guard !candidates.isEmpty else {
            return [] // nothing in seed for this focus; UI can show an empty state
        }

        // Signals with safe defaults
        let successRateByTag = signals.computeSuccessRateByTag(focusId: focusId)
        let preferred = [5,10,20].contains(signals.computeBandwidthPreference(focusId: focusId))
            ? signals.computeBandwidthPreference(focusId: focusId) : 5
        let heatmap = signals.computeTimeOfDayHeatmap()
        let hour = Calendar.current.component(.hour, from: day)
        let hourFit = heatmap[hour] ?? 0.5
        let noveltyTol = signals.computeNoveltyTolerance(focusId: focusId)
        let noveltyOK = (noveltyTol == "med" || noveltyTol == "high")
        let friction = signals.computeFrictionIndex(focusId: focusId)
        let pinned = store.focus(by: focusId)?.pinnedMicroSkillTitles ?? []

        struct Scored { let tpl: ActionTemplate; let score: Double }
        let scored: [Scored] = candidates.map { tpl in
            let focusMatch = scoreFocusMatch(template: tpl, pinned: pinned)
            let successProb = tpl.tags.map { successRateByTag[$0] ?? 0.5 }.average(or: 0.5)
            let bandwidthFit = tpl.variants.contains { $0.durationMinutes == preferred } ? 1.0 : 0.5
            let noveltyBoost = noveltyOK ? 0.2 : 0.0
            let frictionRisk = min(max(friction, 0), 1)
            let s = 0.35*focusMatch + 0.20*successProb + 0.15*bandwidthFit + 0.10*hourFit + 0.10*noveltyBoost + 0.10*1.0 - 0.10*frictionRisk
            return .init(tpl: tpl, score: s)
        }.sorted { $0.score > $1.score }

        // ✅ Fallbacks to guarantee output
        let chosenTemplates: [ActionTemplate]
        if scored.isEmpty {
            // should never happen because candidates non‑empty, but be safe
            chosenTemplates = Array(candidates.prefix(2))
        } else {
            chosenTemplates = Array(scored.prefix(max(2, min(3, scored.count)))).map { $0.tpl }
        }

        // choose variants per template
        var chosenVariants: [Int:Int] = [:]
        for (idx, tpl) in chosenTemplates.enumerated() {
            let durations = tpl.variants.map { $0.durationMinutes }
            chosenVariants[idx] = durations.contains(preferred) ? preferred : (durations.first ?? 5)
        }

        let why = explain.build(
            focusId: focusId,
            preferredDuration: chosenVariants.mode(defaultValue: preferred),
            hour: hour,
            frictionIndex: friction
        )

        return [RankedSuggestion(
            headline: headline(for: focusId),
            actions: chosenTemplates,
            chosenVariants: chosenVariants,
            whySummary: why
        )]
    }
    
    // MARK: - Helper Methods
    
    private func headline(for focusId: String) -> String {
        switch focusId {
        case "independence":   return "You pick the plan; I'm backup"
        case "emotion_skills": return "Name your feeling, invite theirs"
        default:               return "Try this today…"
        }
    }

    private func scoreFocusMatch(template: ActionTemplate, pinned: [String]) -> Double {
        // simple: bump if template title mentions any pinned micro-skill words
        guard !pinned.isEmpty else { return 0.6 }
        let t = template.title.lowercased()
        return pinned.contains(where: { t.contains($0.lowercased()) }) ? 1.0 : 0.6
    }
}

private extension Array where Element == Double {
    func average(or fallback: Double) -> Double { isEmpty ? fallback : reduce(0,+)/Double(count) }
}

private extension Dictionary where Key == Int, Value == Int {
    func mode(defaultValue: Int) -> Int { reduce(into: [:]) { $0[$1.value, default: 0] += 1 }.max(by: { $0.value < $1.value })?.key ?? defaultValue }
}
