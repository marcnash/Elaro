import SwiftUI

struct MonthlyPlanCard: View {
    let focus: FocusArea
    let engines: FocusEngineContainer?
    
    @State private var buildingBlocks: [BuildingBlock] = []
    @State private var pinnedTitles: [String] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Monthly Plan: \(focus.name)")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isLoading {
                ProgressView("Loading plan...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 3 Building Block Tiles
                VStack(spacing: 16) {
                    ForEach(Array(buildingBlocks.enumerated()), id: \.element.id) { index, block in
                        BuildingBlockTileView(
                            type: BuildingBlockTileView.BlockType(rawValue: block.type.capitalized) ?? .microSkill,
                            title: Binding(
                                get: { buildingBlocks[index].title },
                                set: { buildingBlocks[index].title = $0 }
                            ),
                            description: Binding(
                                get: { buildingBlocks[index].desc ?? "" },
                                set: { buildingBlocks[index].desc = $0.isEmpty ? nil : $0 }
                            ),
                            pinned: pinnedTitles.contains(block.title),
                            onTogglePin: {
                                togglePin(for: block.title)
                            }
                        )
                    }
                }
                
                // Optional Boundary chip
                BoundaryChip()
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            loadBuildingBlocks()
        }
        .onChange(of: focus) {
            loadBuildingBlocks()
        }
    }
    
    private func loadBuildingBlocks() {
        guard let engines = engines else { return }
        
        isLoading = true
        DispatchQueue.main.async {
            let blocks = engines.focusPlanner.getBuildingBlocks(for: focus.id)
            let pinned = engines.focusPlanner.getPinnedMicroSkills(for: focus.id)
            
            self.buildingBlocks = blocks
            self.pinnedTitles = pinned
            self.isLoading = false
        }
    }
    
    private func updateBuildingBlock(at index: Int, with block: BuildingBlock) {
        guard let engines = engines else { return }
        
        engines.focusPlanner.updateBuildingBlock(for: focus.id, at: index, block: block)
        buildingBlocks[index] = block
    }
    
    private func togglePin(for title: String) {
        guard let engines = engines else { return }
        
        engines.focusPlanner.togglePin(for: focus.id, title: title)
        
        if pinnedTitles.contains(title) {
            pinnedTitles.removeAll { $0 == title }
        } else {
            pinnedTitles.append(title)
        }
    }
}


struct BoundaryChip: View {
    @State private var boundaryText: String = "Keep bedtime predictable"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Boundary/constraint:")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Optional boundary...", text: $boundaryText)
                .font(.body)
                .foregroundStyle(.secondary)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview("Independence") {
    MonthlyPlanCard(focus: FocusArea(id: FocusKey.independence.rawValue, name: FocusKey.independence.displayName), engines: nil)
}

#Preview("Emotion Skills") {
    MonthlyPlanCard(focus: FocusArea(id: FocusKey.emotionSkills.rawValue, name: FocusKey.emotionSkills.displayName), engines: nil)
}
