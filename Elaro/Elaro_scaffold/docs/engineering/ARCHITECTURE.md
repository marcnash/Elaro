# Architecture

## Patterns
- SwiftUI + MVVM
- Async/await + Combine where appropriate
- Repository pattern between Domain and Data

## Modules (targets or Swift packages)
- Domain: Models, UseCases
- Data: CoreData stack, CloudKitSync (feature flag)
- Features: Dashboard, Library, ChildProfile, Routine, Guidance
- Shared: Design system, Components, Utilities

## Navigation
- Root TabView; feature flows via NavigationStack

## Feature Flags
- JSON at `/Config/feature_flags.json`
- Keys: cloudkit_sync, routines_enabled, export_enabled
