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
                .modelContainer(for: [Milestone.self,
                                      MilestoneProgress.self,
                                      ChildProfile.self,
                                      AppSettings.self,
                                      BehaviorPlanTemplate.self, BehaviorStepTemplate.self,
                                      BehaviorPlanProgress.self, BehaviorStepProgress.self])
                .task {
                    // Seed on first run
                    if let container = try? ModelContainer(for: Milestone.self,
                                                         MilestoneProgress.self,
                                                         ChildProfile.self,
                                                         AppSettings.self,
                                                         BehaviorPlanTemplate.self, 
                                                         BehaviorStepTemplate.self,
                                                         BehaviorPlanProgress.self, 
                                                         BehaviorStepProgress.self) {
                        let ctx = ModelContext(container)
                        await seedIfNeeded(modelContext: ctx)
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
