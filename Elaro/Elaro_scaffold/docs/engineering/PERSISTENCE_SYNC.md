# Persistence & Sync

## Local-First
- Core Data store in App Group container
- Daily autosave + manual export (JSON/CSV)

## Optional Cloud (Phase 3)
- CloudKit private DB; record types mirror entities
- Conflict: last-writer-wins for stage; notes append; timeline merges
