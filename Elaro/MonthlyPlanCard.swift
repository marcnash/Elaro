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
                            block: block,
                            isPinned: pinnedTitles.contains(block.title),
                            onUpdate: { updatedBlock in
                                updateBuildingBlock(at: index, with: updatedBlock)
                            },
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

struct BuildingBlockTileView: View {
    @State var block: BuildingBlock
    let isPinned: Bool
    let onUpdate: (BuildingBlock) -> Void
    let onTogglePin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Pin
            HStack {
                Text(block.type.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: onTogglePin) {
                    Image(systemName: isPinned ? "pin.fill" : "pin")
                        .foregroundColor(isPinned ? .blue : .secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPinned ? "Unpin" : "Pin")
                .accessibilityHint("Tap to \(isPinned ? "unpin" : "pin") this building block")
            }
            
            // Editable Title
            TextField("Title", text: $block.title)
                .font(.headline)
                .fontWeight(.semibold)
                .textFieldStyle(.plain)
                .onChange(of: block.title) {
                    onUpdate(block)
                }
            
            // Editable Description
            TextField("Description", text: Binding(
                get: { block.desc ?? "" },
                set: { block.desc = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
                .font(.body)
                .foregroundStyle(.secondary)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .onChange(of: block.desc) {
                    onUpdate(block)
                }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isPinned ? .blue : .clear, lineWidth: 2)
        )
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
    MonthlyPlanCard(focus: FocusArea(id: "independence", name: "Independence"), engines: nil)
}

#Preview("Emotion Skills") {
    MonthlyPlanCard(focus: FocusArea(id: "emotion_skills", name: "Emotion Skills"), engines: nil)
}
