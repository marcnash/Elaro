import SwiftUI

struct ActionsList: View {
    let actions: [ActionTemplate]
    @State private var selectedVariants: [UUID: Int] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(actions) { action in
                ActionRow(
                    action: action,
                    selectedVariantIndex: selectedVariants[action.id] ?? 0,
                    onVariantChange: { index in
                        selectedVariants[action.id] = index
                    }
                )
            }
        }
    }
}

struct ActionRow: View {
    let action: ActionTemplate
    let selectedVariantIndex: Int
    let onVariantChange: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Action Title
            Text(action.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            // Why Line
            RationaleLine(text: action.whyLine)
            
            // Variant Picker
            VariantPicker(
                variants: action.variants,
                selectedIndex: selectedVariantIndex,
                onSelectionChange: onVariantChange
            )
            
            // Reflection Bar
            ReflectionBar()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct RationaleLine: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionsList(actions: MockContent.independenceToday.actions)
    }
    .padding()
}
