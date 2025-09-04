import SwiftUI

struct ProgressScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                
                Text("Progress")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Coming in Phase 2")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Progress will show trends and narratives by Focus Area, not generic points. You'll see your journey through competency rungs and celebrate meaningful growth.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProgressScreen()
}