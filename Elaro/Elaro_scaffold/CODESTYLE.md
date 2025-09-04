# Code Style

- Swift 5.10+, SwiftUI-first, no storyboards.
- ViewModels: `@MainActor`, immutable inputs, `@Published` outputs.
- Dependency injection via protocols + initializer injection.
- Keep Views < 200 lines where possible; extract subviews.
