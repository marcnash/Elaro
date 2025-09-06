// RecommenderEngine.swift
import Foundation
import SwiftData

struct RankedSuggestion: Identifiable {
    let id = UUID()
    let headline: String
    let actions: [ActionTemplate]        // 1–3
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

    func rank(for focusId: String, day: Date = .now) -> [RankedSuggestion] {
        let candidates = store.actions(for: focusId)
        guard !candidates.isEmpty else { return [] }

        // Signals with safe defaults
        let srByTag = signals.computeSuccessRateByTag(focusId: focusId)
        let pref = [5,10,20].contains(signals.computeBandwidthPreference(focusId: focusId))
            ? signals.computeBandwidthPreference(focusId: focusId) : 5
        let hour = Calendar.current.component(.hour, from: day)
        let heat = signals.computeTimeOfDayHeatmap()[hour] ?? 0.5
        let novOK = ["med","high"].contains(signals.computeNoveltyTolerance(focusId: focusId))
        let friction = max(0, min(1, signals.computeFrictionIndex(focusId: focusId)))
        let pins = store.focus(by: focusId)?.pinnedMicroSkillTitles ?? []

        struct Scored { let tpl: ActionTemplate; let s: Double }
        let scored = candidates.map { tpl -> Scored in
            let focusMatch = scoreFocusMatch(template: tpl, pinned: pins)
            let succ = tpl.tags.map { srByTag[$0] ?? 0.5 }.reduce(0,+) / Double(max(1, tpl.tags.count))
            let bandwidth = tpl.variants.contains { $0.durationMinutes == pref } ? 1.0 : 0.5
            let novelty = novOK ? 0.2 : 0.0
            let s = 0.35*focusMatch + 0.20*succ + 0.15*bandwidth + 0.10*heat + 0.10*novelty + 0.10*1.0 - 0.10*friction
            return .init(tpl: tpl, s: s)
        }
        .sorted { $0.s > $1.s }

        // ✅ Fallback ensures ≥2 actions even with zero signals
        let chosen = (scored.isEmpty ? Array(candidates.prefix(2))
                                     : Array(scored.prefix(max(2, min(3, scored.count)))).map(\.tpl))

        var chosenVariants: [Int:Int] = [:]
        for (i, tpl) in chosen.enumerated() {
            let durations = tpl.variants.map(\.durationMinutes)
            chosenVariants[i] = durations.contains(pref) ? pref : (durations.first ?? 5)
        }

        let why = ExplainWhyBuilder().build(
            focusId: focusId,
            preferredDuration: chosenVariants.values.mostCommon(default: pref),
            hour: hour,
            frictionIndex: friction
        )

        return [RankedSuggestion(
            headline: headline(for: focusId),
            actions: chosen,
            chosenVariants: chosenVariants,
            whySummary: why
        )]
    }

    private func headline(for focusId: String) -> String {
        switch focusId { case "independence": "You pick the plan; I’m backup"
                         case "emotion_skills": "Name your feeling, invite theirs"
                         default: "Try this today…" }
    }
    private func scoreFocusMatch(template: ActionTemplate, pinned: [String]) -> Double {
        guard !pinned.isEmpty else { return 0.6 }
        let t = template.title.lowercased()
        return pinned.contains(where: { t.contains($0.lowercased()) }) ? 1.0 : 0.6
    }
}
private extension Collection where Element == Int {
    func mostCommon(default d: Int) -> Int {
        let freq = reduce(into: [Int:Int]()) { $0[$1, default: 0] += 1 }
        return freq.max(by: { $0.value < $1.value })?.key ?? d
    }
}
