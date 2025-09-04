# Product Brief

## Problem
Parents lack a structured, age-grounded way to build independence. Existing apps optimize for task completion, not development.

## Solution
A parent-facing app that:
- Provides an age-based milestone library
- Guides scaffolding (how to step back)
- Tracks progression: Introduced → Practicing → Independent
- Surfaces coaching nudges for the parent

## Success Metrics (North Stars)
- % milestones moved to **Independent** per child/month
- Weekly active parents (WAP)
- 4-week retention
- % parents using scaffolding tips ≥ 2×/week

## Non-Goals (v1)
- Real-money allowance, external rewards marketplace
- Multi-platform (focus iOS first)

## Risks & Mitigations
- **Overcomplexity:** Keep 6–7 screens; phase advanced settings.
- **Data sensitivity:** Local-first, private by default; explicit CloudKit opt-in.

## Release Targets
- v0.1 (MVP): Dashboard, Library, Child Profile, local persistence
- v0.2: Notifications, basic analytics, export/printable charts
- v1.0: CloudKit sync, localization (EN/ES), accessibility polish
