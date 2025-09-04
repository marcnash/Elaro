import SwiftUI

struct ExplainWhyFooter: View {
    let explainWhy: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("Why these suggestions?")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            Text(explainWhy)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 20)
        }
        .padding(12)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 16) {
        ExplainWhyFooter(
            explainWhy: "Because evenings worked and you picked 5‑min options, here are two 5‑min choices."
        )
        
        ExplainWhyFooter(
            explainWhy: "Because after‑school works best, we're suggesting after‑school options."
        )
    }
    .padding()
}
