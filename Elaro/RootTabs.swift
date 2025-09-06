// RootTabs.swift (or your app’s first view)
import SwiftUI
import SwiftData

struct RootTabs: View {
    @Environment(\.modelContext) private var ctx

    var body: some View {
        TabView {
            FocusDeckScreen()
                .tabItem { Label("Focus", systemImage: "scope") }
            LibraryScreen()
                .tabItem { Label("Library", systemImage: "books.vertical") }
            ProgressScreen()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .task {
            // ✅ Seed into the SAME context the UI uses
            await MainActor.run { SeedImporter.runIfNeeded(context: ctx) }

            // Quick sanity log
            #if DEBUG
            do {
                let all = try ctx.fetch(FetchDescriptor<ActionTemplate>())
                let grouped = Dictionary(grouping: all, by: { $0.focusId }).mapValues(\.count)
                print("[Seed] actions by focus:", grouped)
            } catch { print("[Seed] fetch error:", error) }
            #endif
        }
    }
}
