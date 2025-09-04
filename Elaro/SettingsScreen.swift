import SwiftUI
import SwiftData
import Foundation

struct SettingsScreen: View {
    @Environment(\.modelContext) private var ctx
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]

    @State private var presentingAddChild = false
    @State private var newChildName = ""
    @State private var newChildBirth = Calendar.current.date(byAdding: .year, value: -4, to: Date.now)!

    private var settings: AppSettings {
        if let s = settingsArray.first { return s }
        let s = AppSettings()
        ctx.insert(s); try? ctx.save()
        return s
    }
    
    private func saveNewChild() {
        // Validate input
        let trimmedName = newChildName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Create and insert the new child
        let child = ChildProfile(name: trimmedName, birthdate: newChildBirth)
        ctx.insert(child)
        
        // Save to persistent store
        do {
            try ctx.save()
            
            // Reset form state
            resetForm()
            presentingAddChild = false
            
            // If this is the first child, automatically select them
            if children.isEmpty {
                settings.selectedChildID = child.id
                try? ctx.save()
            }
        } catch {
            print("Failed to save new child: \(error)")
            // In a real app, you'd want to show an error alert here
        }
    }
    
    private func resetForm() {
        newChildName = ""
        newChildBirth = Calendar.current.date(byAdding: .year, value: -4, to: Date.now)!
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus Modes") {
                    let focusModesBinding: Binding<Set<FocusMode.ID>> = Binding(
                        get: { Set(settings.selectedModes.map { $0.id }) },
                        set: { newSelection in
                            settings.selectedModes = FocusMode.allCases.filter { newSelection.contains($0.id) }
                            try? ctx.save()
                        }
                    )
                    
                    FocusModeTileGrid(
                        modes: FocusMode.allCases,
                        selection: focusModesBinding,
                        allowsMultipleSelection: true,
                        title: { $0.label },
                        subtitle: { mode in
                            switch mode {
                            case .milestones: "Core developmental milestones"
                            case .chores: "Household responsibilities"
                            case .behavior: "Behavior management"
                            case .custom: "Custom focus areas"
                            }
                        },
                        icon: { mode in
                            switch mode {
                            case .milestones: Image(systemName: "star.circle")
                            case .chores: Image(systemName: "house.circle")
                            case .behavior: Image(systemName: "brain.head.profile")
                            case .custom: Image(systemName: "slider.horizontal.3")
                            }
                        },
                        onChange: { newSelection in
                            settings.selectedModes = FocusMode.allCases.filter { newSelection.contains($0.id) }
                            try? ctx.save()
                        }
                    )
                }

                Section("Children") {
                    ForEach(children, id: \.id) { c in
                        HStack {
                            Text(c.name)
                            Spacer()
                            Button("Use") { settings.selectedChildID = c.id; try? ctx.save() }
                                .buttonStyle(.bordered)
                        }
                    }
                    Button {
                        presentingAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $presentingAddChild) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $newChildName)
                        DatePicker("Birthdate", selection: $newChildBirth, displayedComponents: .date)
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { 
                                presentingAddChild = false
                                resetForm()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveNewChild()
                            }.disabled(newChildName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .navigationTitle("New Child")
                    .onAppear {
                        resetForm()
                    }
                }
            }
        }
    }
}

// MARK: - Unused Generic Views (Commented Out)
// These views are not used in this file and could cause compiler issues
// due to complex generic expressions like Text(String(describing: (item as? FocusMode)?.label ?? "\(item)"))

/*
// Simple horizontal multiselect chips
struct FlowChips<T: Identifiable & Hashable>: View where T: CaseIterable, T.AllCases == Array<T> {
    let all: [T]
    @Binding var selection: Set<T>

    var body: some View {
        VStack(alignment: .leading) {
            Wrap(alignment: .leading, spacing: 8) {
                ForEach(all) { item in
                    let isOn = selection.contains(item)
                    Text(String(describing: (item as? FocusMode)?.label ?? "\(item)"))
                        .font(.callout)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(isOn ? Capsule().fill(.thinMaterial) : Capsule().strokeBorder(.gray.opacity(0.4)))
                        .onTapGesture {
                            if isOn { selection.remove(item) } else { selection.insert(item) }
                        }
                }
            }
        }
    }
}

// Minimal wrap layout helper
struct Wrap<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        // For simplicity, a scrollable row; replace with a true wrap layout if desired.
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: spacing) { content() } }
    }
}
*/
