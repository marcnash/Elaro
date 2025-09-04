import SwiftUI
import SwiftData
import Foundation

struct ProgressOverviewScreen: View {
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
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date.now)) ?? Date.now
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start
        let p = #Predicate<MilestoneProgress> { p in p.weekOf >= start && p.weekOf < end }
        _progresses = Query(filter: p)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header

                let stats = overallStats()
                HStack(spacing: 24) {
                    ProgressRing(title: "Independent", fraction: stats.independentFrac)
                    ProgressRing(title: "Practicing", fraction: stats.practicingFrac)
                    ProgressRing(title: "Introduced", fraction: stats.introducedFrac)
                }
                .padding(.horizontal)

                // Category rings
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(Category.allCases, id: \.self) { cat in
                        let s = categoryFrac(cat)
                        ProgressRing(title: cat.title, fraction: s)
                    }
                }
                .padding()
                Spacer(minLength: 0)
            }
            .navigationTitle("Overview")
        }
    }

    private var filteredMilestones: [Milestone] {
        guard let modes = settings?.selectedModes, !modes.isEmpty else { return allMilestones }
        let allowed = Set(modes.flatMap { $0.allowedKinds })
        return allMilestones.filter { allowed.contains($0.kind) }
    }

    private func currentWeekBounds() -> (Date, Date) {
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear,.weekOfYear], from: weekOf)) ?? weekOf
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start
        return (start, end)
    }

    private func overallStats() -> (independentFrac: Double, practicingFrac: Double, introducedFrac: Double) {
        guard let child = selectedChild else { return (0,0,0) }
        let (start, end) = currentWeekBounds()
        let week = progresses.filter { $0.child.id == child.id && $0.weekOf >= start && $0.weekOf < end }
        let ids = Set(filteredMilestones.map { $0.id })
        let weekForFiltered = week.filter { ids.contains($0.milestone.id) }

        let total = max(1, filteredMilestones.count) // avoid div-by-zero
        let ind = weekForFiltered.filter { $0.stage == .independent }.map { $0.milestone.id }.uniqued.count
        let prac = weekForFiltered.filter { $0.stage == .practicing }.map { $0.milestone.id }.uniqued.count
        let intro = weekForFiltered.filter { $0.stage == .introduced }.map { $0.milestone.id }.uniqued.count
        return (Double(ind)/Double(total), Double(prac)/Double(total), Double(intro)/Double(total))
    }

    private func categoryFrac(_ cat: Category) -> Double {
        guard let child = selectedChild else { return 0 }
        let (start, end) = currentWeekBounds()
        let ms = filteredMilestones.filter { $0.category == cat }
        guard !ms.isEmpty else { return 0 }
        let ids = Set(ms.map { $0.id })
        let week = progresses.filter { $0.child.id == child.id && $0.weekOf >= start && $0.weekOf < end && ids.contains($0.milestone.id) }
        let independent = Set(week.filter { $0.stage == .independent }.map { $0.milestone.id }).count
        let total = ms.count
        guard total > 0 else { return 0 }
        let result = Double(independent) / Double(total)
        return result.isNaN ? 0 : result
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

            DatePicker("", selection: $weekOf, displayedComponents: .date).labelsHidden()
        }
        .padding(.horizontal)
    }
}

private struct ProgressRing: View {
    let title: String
    let fraction: Double        // 0...1

    var body: some View {
        VStack {
            ZStack {
                Circle().stroke(lineWidth: 10).opacity(0.15)
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(fraction.isNaN ? 0 : fraction, 0), 1)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: fraction)
                Text("\(Int((fraction.isNaN ? 0 : fraction) * 100))%").font(.headline).monospacedDigit()
            }
            .frame(width: 90, height: 90)
            Text(title).font(.caption)
        }
    }
}

private extension Array where Element: Hashable {
    var uniqued: [Element] { Array(Set(self)) }
}
