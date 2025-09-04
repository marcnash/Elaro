import SwiftUI

struct VariantPicker: View {
    let variants: [ActionVariant]
    let selectedIndex: Int
    let onSelectionChange: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose duration:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                ForEach(Array(variants.enumerated()), id: \.offset) { index, variant in
                    VariantButton(
                        variant: variant,
                        isSelected: selectedIndex == index,
                        onTap: {
                            onSelectionChange(index)
                        }
                    )
                }
            }
        }
    }
}

struct VariantButton: View {
    let variant: ActionVariant
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(variant.durationMinutes) min")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("\(variant.steps.count) steps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .blue : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.blue, lineWidth: isSelected ? 0 : 1)
                    )
            )
            .foregroundColor(isSelected ? .white : .blue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(variant.durationMinutes) minute option")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        VariantPicker(
            variants: MockContent.independenceToday.actions.first?.variants ?? [],
            selectedIndex: 0,
            onSelectionChange: { _ in }
        )
    }
    .padding()
}
