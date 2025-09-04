import SwiftUI
import SwiftData

struct FocusModeTileGrid<Mode: Identifiable & Hashable>: View {
    let modes: [Mode]
    @Binding var selection: Set<Mode.ID>
    var allowsMultipleSelection: Bool = true
    var title: (Mode) -> String
    var subtitle: ((Mode) -> String)? = nil
    var icon: ((Mode) -> Image)? = nil
    var onChange: ((Set<Mode.ID>) -> Void)? = nil

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(modes, id: \.id) { mode in
                TileView(
                    mode: mode,
                    isSelected: selection.contains(mode.id),
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    onTap: { toggle(mode) }
                )
            }
        }
        .animation(.snappy(duration: 0.15), value: selection)
    }

    private func toggle(_ mode: Mode) {
        if allowsMultipleSelection {
            if selection.contains(mode.id) { selection.remove(mode.id) } else { selection.insert(mode.id) }
        } else {
            selection = selection.contains(mode.id) ? [] : [mode.id]
        }
        onChange?(selection)
    }
}

// MARK: - Tile View Component
private struct TileView<Mode: Identifiable & Hashable>: View {
    let mode: Mode
    let isSelected: Bool
    let title: (Mode) -> String
    let subtitle: ((Mode) -> String)?
    let icon: ((Mode) -> Image)?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with icon and checkmark
                HStack {
                    if let icon = icon?(mode) {
                        icon
                            .imageScale(.large)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .accessibilityHidden(true)
                    }
                }

                // Title
                Text(title(mode))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Subtitle (if provided)
                if let subtitle {
                    Text(subtitle(mode))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .frame(minHeight: 96)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? .primary.opacity(0.25) : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title(mode)))
        .accessibilityHint(Text(isSelected ? "Selected" : "Not selected"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
