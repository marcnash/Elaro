import SwiftUI

struct CoachMark: View {
    @State private var visible = true
    var body: some View {
        if visible {
            HStack {
                Spacer()
                Label("Swipe to see Week, Month, Season", systemImage: "hand.point.right.fill")
                    .font(.footnote)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 6, y: 3)
                Spacer()
            }
            .padding(.bottom, 72)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation(.easeOut(duration: 0.4)) { visible = false }
            }
            .accessibilityHidden(true)
        }
    }
}
