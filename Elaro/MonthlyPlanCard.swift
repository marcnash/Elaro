import SwiftUI

struct MonthlyPlanCard: View {
    let focus: FocusArea
    
    private var buildingBlocks: [BuildingBlock] {
        MockContent.monthlyPlan(for: focus)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Monthly Plan: \(focus.displayName)")
                .font(.title2)
                .fontWeight(.semibold)
            
            // 3 Building Block Tiles
            VStack(spacing: 16) {
                ForEach(buildingBlocks) { block in
                    BuildingBlockTileView(block: block)
                }
            }
            
            // Optional Boundary chip
            BoundaryChip()
            
            Spacer(minLength: 0)
        }
    }
}

struct BuildingBlockTileView: View {
    @State var block: BuildingBlock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Pin
            HStack {
                Text(block.type.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    block.isPinned.toggle()
                    print("Pin toggled for \(block.type.displayName)")
                }) {
                    Image(systemName: block.isPinned ? "pin.fill" : "pin")
                        .foregroundColor(block.isPinned ? .blue : .secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(block.isPinned ? "Unpin" : "Pin")
                .accessibilityHint("Tap to \(block.isPinned ? "unpin" : "pin") this building block")
            }
            
            // Editable Title
            TextField("Title", text: $block.title)
                .font(.headline)
                .fontWeight(.semibold)
                .textFieldStyle(.plain)
            
            // Editable Description
            TextField("Description", text: $block.description, axis: .vertical)
                .font(.body)
                .foregroundStyle(.secondary)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(block.isPinned ? .blue : .clear, lineWidth: 2)
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
    MonthlyPlanCard(focus: .independence)
}

#Preview("Emotion Skills") {
    MonthlyPlanCard(focus: .emotionSkills)
}
