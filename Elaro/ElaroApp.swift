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
    var container: ModelContainer = {
        let schema = Schema([
            FocusArea.self, BuildingBlock.self, ActionTemplate.self,
            TemplateVariant.self, ActionInstance.self, WeeklySummary.self
        ])
        let config = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
        .task {
            // Seed on first run
            let ctx = ModelContext(container)
            await SeedImporter.run(modelContext: ctx)
        }
    }
}

struct RootView: View {
    var body: some View {
        RootTabs()
    }
}
