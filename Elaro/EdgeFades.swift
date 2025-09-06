import SwiftUI

struct EdgeFades: View {
    let showLeft: Bool
    let showRight: Bool
    var body: some View {
        HStack {
            LinearGradient(colors: [.clear, Color(.systemBackground).opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                .frame(width: 16).opacity(showLeft ? 1 : 0)
            Spacer()
            LinearGradient(colors: [Color(.systemBackground).opacity(0.75), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: 16).opacity(showRight ? 1 : 0)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
