# Elaro (iOS)

Parent-facing milestone & scaffolding tracker for age-appropriate independence skills.

## TL;DR
- **Audience:** Parents/caregivers
- **Value:** Track *developmental milestones* (Introduced → Practicing → Independent), not just chores.
- **Tech:** SwiftUI, MVVM, Core Data (+ CloudKit optional), Combine, Swift Concurrency.

## Modules
- **Wireframe** (`ElaroWireframe.swift`) - Complete SwiftUI prototype with sample data
- AppShell (navigation, theming)
- Domain (models, use cases)
- Data (Core Data, CloudKit sync)
- Features
  - Dashboard
  - Milestone Library
  - Child Profile
  - Chore (Routine) Tracker
  - Parent Guidance
- Shared (UI components)

## Getting Started
1. Xcode 16+, iOS 17+
2. `git clone <your-repo-url>`
3. Open `Elaro.xcodeproj`
4. Run target `Elaro-Dev`

## Quick Start with Wireframe
The scaffold includes a complete SwiftUI wireframe (`ElaroWireframe.swift`) that demonstrates:
- **Interactive UI components** for milestone tracking
- **Sample data** to test functionality immediately
- **Full app flow** with dashboard, child profiles, and routine tracking
- **SwiftUI previews** for rapid development iteration

## Environments
- Dev (local Core Data store)
- Prod (CloudKit container: `iCloud.com.example.Elaro`)

## Links
- Product brief: `/docs/product/PRODUCT_BRIEF.md`
- Architecture: `/docs/engineering/ARCHITECTURE.md`
- Data model: `/docs/engineering/DATA_MODEL.md`
