import SwiftUI

struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    CardContainer {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sample Card Content")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This is a preview of the card container with some sample content to demonstrate the layout and styling.")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Button("Sample Action") {
                print("Button tapped")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    .frame(height: 400)
}
