import SwiftUI

/// Flowing, adaptive grid of selectable chips.
/// - Generic over any `Hashable` item; supply a `label` that maps item -> String.
/// - Uses enumerated ForEach to avoid the Binding-based initializer ambiguity.
public struct FlowChipsGrid<T: Hashable>: View {
    public let all: [T]
    @Binding public var selection: Set<T>
    public var label: (T) -> String

    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    public init(all: [T], selection: Binding<Set<T>>, label: @escaping (T) -> String) {
        self.all = all
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(Array(all.enumerated()), id: \.offset) { _, item in
                let isOn = selection.contains(item)
                Chip(title: label(item), isOn: isOn)
                    .onTapGesture { toggle(item) }
            }
        }
        .animation(.easeInOut, value: selection)
    }

    private func toggle(_ item: T) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}

private struct Chip: View {
    let title: String
    let isOn: Bool

    var body: some View {
        Text(title)
            .font(.callout)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isOn ? Color(.systemFill) : Color.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.4), lineWidth: isOn ? 0 : 1)
            )
    }
}
