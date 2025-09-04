# Architecture

_Last updated: 2025‑09‑04_

## Guiding Principles
- **On‑device by default:** scoring, signals, and recommendations run locally.  
- **Explainable:** every suggestion ships with a compact “why” string.  
- **Modular:** isolate Content, Signals, Recommender, Weekly Adjuster, Focus Planner, Persistence.  
- **Humane performance:** snappy (<150ms) suggestions; zero‑jank UI; accessible by default.

## System Overview
```
User Input (completion, difficulty, notes)
        ↓
Signals Calculator  ──►  Focus Planner (Monthly)
        ↓                         ↓
Daily Recommender (Today)   Weekly Adjuster (Keep/Adjust)
        ↓                         ↓
          UI (Today / Week / Month / Season)
        ↑            │
        └────────────┘  feedback loop
```

### Modules
**Content Library**  
Human‑authored `ActionTemplate`s tagged by Focus, with 5/10/20‑minute variants and contraindications. Shipped in bundle; versioned.

**Signals Calculator**  
Derives `successRateByTag`, `timeOfDayHeatmap`, `bandwidthPreference`, `noveltyTolerance`, `frictionIndex` from `ActionInstance`s (rolling windows).

**Daily Recommender**  
Ranks candidate `ActionTemplate` variants for the active Focus using the **explainable score** (see Data Model). Returns top **2–3**. Produces `whySummary` (e.g., “FocusMatch • TimeOfDayFit”).

**Weekly Adjuster**  
Summarizes last 7 days, emits exactly one suggestion: **Keep / Scale down / Scale up** (+ one‑line rationale). Writes `WeeklySummary`.

**Focus Planner (Monthly)**  
Proposes **3 building blocks** (Micro‑skill, Ritual, Support). Parent accepts/edits. Updates which tags the recommender should bias.

**Persistence**  
SwiftData (iOS 17+) for local data; background app refresh to precompute signals; idempotent seed import with `contentVersion`.

**Notifications**  
One gentle daily nudge; optional morning preview; weekly digest. All opt‑in; schedule respects `timeOfDayHeatmap`.

**Feature Flags**  
Local JSON first; optional remote toggles. Gate: Weekly/Monthly, Digest, Coping Kit, AI assists.

**Analytics (privacy‑first)**  
Minimal, structured events; local queue; user‑controlled upload (off by default). No raw notes by default.

## Data Flow (happy path)
1) App loads → Content Library hydrated → Signals precomputed (if cache is stale).  
2) Recommender selects 2–3 actions → Today card renders.  
3) Parent chooses/finishes → write `ActionInstance` → update Signals → refresh Today (if applicable).  
4) End of week → Weekly Adjuster writes `WeeklySummary` and suggested tweak.  
5) Monthly → Focus Planner proposes 3 building blocks → parent accepts/edits → biases recommender.

## Explainability Hooks
Each suggestion includes:
- `reasons: [FocusMatch, SuccessProbability, BandwidthFit, TimeOfDayFit, NoveltyBoost, StreakMomentum, FrictionRisk]`
- `whySummary: String` (e.g., “Because evenings worked and you picked 5‑min options, here are two 5‑min choices.”)

## Performance Targets
- Suggestion compute ≤150ms on mid‑range devices; prefetch after completion.  
- Background signals update <300ms; debounce writes.  
- Launch to interactive ≤2s with cached Today content.

## Accessibility & i18n
- Dynamic Type across UI; 44pt+ targets; VoiceOver labels for toggles/chips; Reduced Motion safe animations.  
- Plain‑language copy, grade‑6–8 reading level; idioms avoided; localization‑ready strings.

## Security & Privacy
- On‑device data by default; optional iCloud/CloudKit sync (later) with encrypted fields.  
- No raw note upload by default; explicit opt‑in if we offer cloud features.  
- Data export/delete controls; diagnostic mode redacts PII.

## Observability
- Lightweight in‑app debug panel: feature flags, seed version, signals snapshot.  
- Analytics events (see Data Model) behind user consent; sampling allowed.

## Testing Strategy
- **Unit:** Signals calc, scoring, step‑up/down, friction dampener.  
- **Snapshot/UI:** Today/Week/Month card states (empty, success, friction).  
- **Integration:** persistence + recommender determinism; seed migrations idempotent.  
- **Manual a11y checks:** VoiceOver paths, Dynamic Type, motion reduction.

## Failure & Edge Handling
- **No actions available:** show empathetic empty state + link to Library.  
- **High friction:** auto‑offer Coping Kit; pause novelty/difficulty; defer scoring.  
- **Notifications denied:** surface weekly digest inside the app; avoid nagging.  
- **Seed mismatch:** log version mismatch; re‑import idempotently.

## Future Extensions (behind flags)
- Contextual bandit for `SuccessProbability`.  
- On‑device note summarization to Win/Hard strings.  
- Co‑parent conflict smoothing (soft‑locks, per‑user notes).

**Cross‑links**  
Product method: `Elaro_scaffold/docs/product/PRODUCT_METHOD_FOCUS_AREA.md`  
Architecture: `/docs/engineering/ARCHITECTURE.md`  
Product brief: `/docs/product/PRODUCT_BRIEF.md`

