import SwiftUI

struct WinHardTweakView: View {
    let win: String
    let hard: String
    let suggestion: String
    let onDecision: (TweakDecision) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(win.isEmpty ? "We'll capture a win soon." : win, systemImage: "checkmark.seal")
            Label(hard.isEmpty ? "We'll note what's hard soon." : hard, systemImage: "exclamationmark.triangle")

            Divider().padding(.vertical, 4)
            Text("Suggested tweak: \(suggestion)").font(.headline)

            HStack {
                Button("Keep")      { onDecision(.keep) }
                Spacer()
                Button("Scale down"){ onDecision(.scaleDown) }
                Spacer()
                Button("Scale up")  { onDecision(.scaleUp) }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
