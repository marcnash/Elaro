import SwiftUI

struct DepthDots: View {
    @Binding var selection: DepthRail.Depth
    private let items: [DepthRail.Depth] = [.today, .week, .month, .season]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { d in
                Circle()
                    .frame(width: selection == d ? 8 : 6, height: selection == d ? 8 : 6)
                    .opacity(selection == d ? 0.95 : 0.4)
                    .animation(.easeInOut(duration: 0.2), value: selection)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { selection = d }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .accessibilityLabel(Text(label(d)))
                    .accessibilityAddTraits(selection == d ? .isSelected : [])
            }
        }
        .padding(10)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().strokeBorder(.separator.opacity(0.2)))
        .clipShape(Capsule())
    }

    private func label(_ d: DepthRail.Depth) -> String {
        switch d { case .today: "Today"; case .week: "Week"; case .month: "Month"; case .season: "Season" }
    }
}
