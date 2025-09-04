import SwiftUI
import SwiftData
import Foundation

struct WeeklySummaryScreen: View {
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]
    @Query(sort: \Milestone.title) private var allMilestones: [Milestone]
    @Query private var progresses: [MilestoneProgress]

    @State private var weekOf: Date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date.now)) ?? Date.now

    private var settings: AppSettings? { settingsArray.first }
    private var selectedChild: ChildProfile? {
        guard let id = settings?.selectedChildID else { return children.first }
        return children.first(where: { $0.id == id })
    }

    init() {
        // Simple query - we'll filter in code to avoid predicate compilation issues
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header

                List {
                    ForEach(Category.allCases, id: \.self) { cat in
                        let (pct, independent, total) = categoryStats(cat)
                        HStack {
                            VStack(alignment: .leading) {
                                Text(cat.title).font(.body)
                                Text("\(independent)/\(total) Independent").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            ProgressView(value: pct)
                                .frame(width: 140)
                                .accessibilityLabel("\(Int(pct * 100))%")
                            Text("\(Int(pct * 100))%").monospacedDigit()
                                .frame(width: 44, alignment: .trailing)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Weekly Summary")
        }
    }

    private var filteredMilestones: [Milestone] {
        guard let modes = settings?.selectedModes, !modes.isEmpty else { return allMilestones }
        let allowed = Set(modes.flatMap { $0.allowedKinds })
        return allMilestones.filter { allowed.contains($0.kind) }
    }

    private func categoryStats(_ cat: Category) -> (pct: Double, independent: Int, total: Int) {
        let ms = filteredMilestones.filter { $0.category == cat }
        guard !ms.isEmpty, let child = selectedChild else { return (0, 0, 0) }

        // limit to current weekOf (user-adjustable)
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear,.weekOfYear], from: weekOf)) ?? weekOf
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start

        let currentWeek = progresses.filter { $0.child.id == child.id && $0.weekOf >= start && $0.weekOf < end }

        let byMilestone = Dictionary(grouping: currentWeek, by: { $0.milestone.id })
        let independentCount = ms.reduce(0) { acc, m in
            let isInd = byMilestone[m.id]?.contains(where: { $0.stage == .independent }) ?? false
            return acc + (isInd ? 1 : 0)
        }
        let pct = ms.isEmpty ? 0.0 : {
            let result = Double(independentCount) / Double(ms.count)
            return result.isNaN ? 0.0 : result
        }()
        return (pct, independentCount, ms.count)
    }

    private var header: some View {
        HStack {
            Menu {
                ForEach(children, id: \.id) { child in
                    Button(child.name) {
                        if let s = settingsArray.first {
                            s.selectedChildID = child.id
                            try? s.modelContext?.save()
                        }
                    }
                }
            } label: {
                Label(selectedChild?.name ?? "Select Child", systemImage: "person.crop.circle")
            }

            DatePicker("", selection: $weekOf, displayedComponents: .date)
                .labelsHidden()
                .onChange(of: weekOf) { /* Query already filters by init; simple view recompute is fine */ }
        }
        .padding(.horizontal)
    }
}
