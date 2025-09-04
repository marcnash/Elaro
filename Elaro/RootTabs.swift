import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            FocusDeckScreen()
                .tabItem {
                    Label("Focus", systemImage: "target")
                }
            
            LibraryScreen()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
            
            ProgressScreen()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}

#Preview {
    RootTabs()
}