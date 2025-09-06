// EngineDebugOverlay.swift
import SwiftUI

struct EngineDebugOverlay: View {
    let focusId: String
    let actionCount: Int
    let why: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DEBUG · \(focusId)").font(.caption).bold()
            Text("actions: \(actionCount)").font(.caption)
            if !why.isEmpty { Text(why).font(.caption2) }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
        .padding([.top, .leading])
    }
}
