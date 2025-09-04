import SwiftUI

struct FocusDeckScreen: View {
    @State private var selectedFocus: FocusArea = .independence
    @State private var depth: FocusDepth = .today
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FocusUtilityBar(
                    selectedFocus: $selectedFocus,
                    depth: $depth
                )
                
                // Simple placeholder for now
                VStack(spacing: 20) {
                    Text("Focus Deck")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Selected Focus: \(selectedFocus.displayName)")
                        .font(.headline)
                    
                    Text("Current Depth: \(depth.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Phase 1 implementation coming soon...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FocusDeckScreen()
}