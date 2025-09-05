import SwiftUI

struct BuildingBlockTileView: View {
    enum BlockType: String { case microSkill = "Micro-skill", ritual = "Ritual", support = "Support" }

    let type: BlockType
    @Binding var title: String
    @Binding var description: String
    let pinned: Bool
    let onTogglePin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(type.rawValue).font(.subheadline).opacity(0.7)
                Spacer()
                Button(pinned ? "Pinned" : "Pin", action: onTogglePin)
                    .buttonStyle(.borderedProminent)
            }
            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 3, y: 2)
    }
}
