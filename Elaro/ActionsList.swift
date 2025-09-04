import SwiftUI

struct ActionsList: View {
    let actions: [ActionTemplate]
    let engines: FocusEngineContainer?
    let focusId: String
    @State private var selectedVariants: [String: Int] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(actions) { action in
                ActionRow(
                    action: action,
                    selectedVariantIndex: selectedVariants[action.id] ?? 0,
                    onVariantChange: { index in
                        selectedVariants[action.id] = index
                    },
                    onStatusChange: { status, difficulty, note in
                        saveActionInstance(action: action, status: status, difficulty: difficulty, note: note)
                    }
                )
            }
        }
    }
    
    private func saveActionInstance(action: ActionTemplate, status: String, difficulty: String?, note: String?) {
        guard let engines = engines else { return }
        
        let selectedVariantIndex = selectedVariants[action.id] ?? 0
        let variant = action.variants[selectedVariantIndex]
        
        let instance = ActionInstance(
            id: UUID().uuidString,
            date: Date.now,
            focusId: focusId,
            templateId: action.id,
            variantDuration: variant.durationMinutes,
            status: status,
            feltDifficulty: difficulty,
            note: note
        )
        
        engines.store.save(instance: instance)
    }
}

struct ActionRow: View {
    let action: ActionTemplate
    let selectedVariantIndex: Int
    let onVariantChange: (Int) -> Void
    let onStatusChange: (String, String?, String?) -> Void
    
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
            ReflectionBar(onStatusChange: onStatusChange)
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
        ActionsList(actions: MockContent.independenceToday.actions, engines: nil, focusId: "independence")
    }
    .padding()
}
