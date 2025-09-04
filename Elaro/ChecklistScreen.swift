import SwiftUI
import SwiftData
import Foundation

struct ChecklistScreen: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Milestone.title) private var milestones: [Milestone]
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]

    @State private var weekOf: Date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date.now)) ?? Date.now

    private var settings: AppSettings? { settingsArray.first }

    private var selectedChild: ChildProfile? {
        guard let id = settings?.selectedChildID else { return children.first }
        return children.first(where: { $0.id == id })
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                header
                List {
                    ForEach(filteredMilestonesGroupedByCategory.keys.sorted(by: { $0.title < $1.title }), id: \.self) { cat in
                        Section(cat.title) {
                            ForEach(filteredMilestonesGroupedByCategory[cat] ?? [], id: \.id) { m in
                                MilestoneRow(milestone: m, child: selectedChild, weekOf: weekOf)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Milestones")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Menu {
                    ForEach(children, id: \.id) { child in
                        Button(child.name) { setSelectedChild(child.id) }
                    }
                } label: {
                    Label(selectedChild?.name ?? "Select Child", systemImage: "person.crop.circle")
                }

                DatePicker("", selection: $weekOf, displayedComponents: .date)
                    .labelsHidden()
            }

            // Quick chips showing active focus modes
            if let modes = settings?.selectedModes {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(modes, id: \.id) { mode in
                            Text(mode.label)
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Capsule().strokeBorder(.gray.opacity(0.4)))
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(.horizontal)
    }

    private func setSelectedChild(_ id: UUID) {
        guard let s = settings else { return }
        s.selectedChildID = id
        try? ctx.save()
    }

    // Filter milestones by selected focus modes -> allowed kinds
    private var filteredMilestones: [Milestone] {
        guard let modes = settings?.selectedModes, !modes.isEmpty else { return milestones }
        let allowed = Set(modes.flatMap { $0.allowedKinds })
        return milestones.filter { allowed.contains($0.kind) }
    }

    private var filteredMilestonesGroupedByCategory: [Category: [Milestone]] {
        Dictionary(grouping: filteredMilestones, by: { $0.category })
    }
}

// MARK: - Row
struct MilestoneRow: View {
    @Environment(\.modelContext) private var ctx
    @Query private var allProgresses: [MilestoneProgress]

    let milestone: Milestone
    let child: ChildProfile?
    let weekOf: Date

    @State private var notes: String = ""

    init(milestone: Milestone, child: ChildProfile?, weekOf: Date) {
        self.milestone = milestone
        self.child = child
        self.weekOf = weekOf
    }

    private var current: MilestoneProgress? { 
        // Filter progresses to find the matching one for this milestone, child, and week
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekOf)) ?? weekOf
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        
        return allProgresses.first { progress in
            progress.milestone.id == milestone.id &&
            progress.weekOf >= weekStart && progress.weekOf < weekEnd &&
            (child == nil ? true : progress.child.id == child?.id)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(milestone.title).font(.body)
                Spacer()
                StagePicker(stage: current?.stage ?? .introduced) { newStage in
                    save(stage: newStage)
                }
            }
            if let detail = milestone.detail, !detail.isEmpty {
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }

            DisclosureGroup("Notes") {
                TextEditor(text: Binding(
                    get: { current?.notes ?? notes },
                    set: { save(notes: $0) }
                ))
                .frame(minHeight: 60)
            }
            .font(.caption)
            
            if milestone.kind == .behavior, let child {
                BehaviorPlanPanel(milestone: milestone, child: child, weekOf: weekOf)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }

    private func save(stage: Stage? = nil, notes: String? = nil) {
        guard let child else { return }
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekOf)) ?? weekOf

        let record = current ?? MilestoneProgress(child: child, milestone: milestone, stage: .introduced, notes: nil, weekOf: weekStart)
        if current == nil { ctx.insert(record) }
        if let stage { record.stage = stage }
        if let notes { record.notes = notes }
        try? ctx.save()
    }
}

struct StagePicker: View {
    var stage: Stage
    var onChange: (Stage) -> Void

    var body: some View {
        Menu {
            ForEach(Stage.allCases) { s in
                Button(s.label) { onChange(s) }
            }
        } label: {
            Label(stage.label, systemImage: "checkmark.circle")
        }
    }
}
