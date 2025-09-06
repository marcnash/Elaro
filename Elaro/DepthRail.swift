import SwiftUI

struct DepthRail: View {
    enum Depth: CaseIterable, Hashable { case today, week, month, season }
    @Binding var selection: Depth
    @Namespace private var ns

    private let labels: [(Depth, String)] = [
        (.today, "Today"), (.week, "Week"), (.month, "Month"), (.season, "Season")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(labels, id: \.0) { depth, title in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                        selection = depth
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(title)
                        .font(.callout.weight(selection == depth ? .semibold : .regular))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selection == depth {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .matchedGeometryEffect(id: "pill", in: ns)
                                        .shadow(radius: 8, y: 4).opacity(0.9)
                                }
                            }
                        )
                        .foregroundStyle(selection == depth ? .primary : .secondary)
                        .contentShape(Rectangle())
                        .accessibilityLabel(Text(title))
                        .accessibilityAddTraits(selection == depth ? .isSelected : [])
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Capsule().fill(.thinMaterial).opacity(0.9))
        .overlay(Capsule().strokeBorder(.separator.opacity(0.2)))
        .clipShape(Capsule())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Depth")
    }
}
