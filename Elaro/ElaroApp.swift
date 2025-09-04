//
//  ElaroApp.swift
//  Elaro
//
//  Created by mnash on 9/3/25.
//

import SwiftUI
import SwiftData

@main
struct ElaroApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [FocusArea.self, BuildingBlock.self, ActionTemplate.self,
                                      TemplateVariant.self, ActionInstance.self, WeeklySummary.self])
                .task {
                    // Seed on first run
                    if let container = try? ModelContainer(for: FocusArea.self, BuildingBlock.self, ActionTemplate.self,
                                                         TemplateVariant.self, ActionInstance.self, WeeklySummary.self) {
                        let ctx = ModelContext(container)
                        await SeedImporter.run(modelContext: ctx)
                    }
                }
        }
    }
}

struct RootView: View {
    var body: some View {
        RootTabs()
    }
}
