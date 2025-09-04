# Data Model

_Last updated: 2025‑09‑04_

## Overview
This document defines entities, derived signals, scoring, adaptation rules, analytics events, and seeding/versioning for the Focus Area method. All data is stored on‑device (SwiftData) by default.

## Entities

### FocusArea
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| name | enum | e.g., `independence`, `emotion_skills`, `connection`, `executive_skills` |
| active | Bool | max 2 active (policy) |
| startedAt | Date | |
| buildingBlocks | [BuildingBlock] | exactly 3 when configured |

### BuildingBlock (discriminated union)
| Field | Type | Notes |
|---|---|---|
| type | enum | `microSkill` \| `ritual` \| `support` |
| title | String | short, parent‑friendly |
| description | String | optional |
| tags | [String] | e.g., `choice_making`, `sequencing` |

### ActionTemplate
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| focusId | UUID | FK → FocusArea |
| title | String | action title |
| whyLine | String | 1‑line rationale |
| tags | [String] | used by Signals and scoring |
| difficulty | Int | 1..5 (relative) |
| variants | [TemplateVariant] | e.g., 5/10/20‑minute |
| contraindications | [String] | e.g., `skip_if_dysregulated` |
| contentVersion | Int | for seed migrations |

### TemplateVariant
| Field | Type |
|---|---|
| durationMinutes | Int (5/10/20) |
| steps | [String] |

### ActionInstance
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| date | Date | local day bucket |
| templateId | UUID | FK → ActionTemplate |
| variantDuration | Int | 5/10/20 |
| status | enum | `done` \| `snoozed` \| `skipped` |
| feltDifficulty | enum | `light` \| `ok` \| `hard` |
| mood | enum? | optional |
| note | String? | optional, on‑device by default |

### WeeklySummary
| Field | Type | Notes |
|---|---|---|
| weekStart | Date | Monday‑based week |
| winText | String | may be auto‑suggested |
| hardText | String | may be auto‑suggested |
| suggestedTweak | enum | `keep` \| `scale_down` \| `scale_up` |

### Signals (derived, per user & focus)
| Signal | Type | How computed |
|---|---|---|
| successRateByTag | Map<String,Double> | done/shown (7‑day rolling) |
| timeOfDayHeatmap | Map<Int,Double> | completions by hour bucket |
| bandwidthPreference | enum (5|10|20) | most‑selected variant over 14 days |
| noveltyTolerance | enum (low|med|high) | completion vs novelty deltas |
| frictionIndex | Double 0..1 | % `hard` + stress keywords rolling 7 days |

## Scoring (Today)
Explainable score for ranking candidate templates:
```
priorityScore =
  0.35 * FocusMatch          // tags overlap with active Focus + building blocks
+ 0.20 * SuccessProbability  // per user & tag cluster, from recent outcomes
+ 0.15 * BandwidthFit        // matches preferred 5/10/20‑min
+ 0.10 * TimeOfDayFit        // aligns with heatmap
+ 0.10 * NoveltyBoost        // gentle novelty if tolerance ≥ med
+ 0.10 * StreakMomentum      // protect rituals/routines
- 0.10 * FrictionRisk        // penalize patterns marked ‘hard’
```
**Output:** top 2–3 `ActionTemplate` variants + `reasons[]` and a `whySummary` string.

## Adaptation Rules
- **Step‑up:** if ≥3 successes in last 4 attempts with ≤1 `hard` → propose slightly harder cousin.  
- **Step‑down:** if ≥2 `hard` or 2 skips in last 4 → swap to easier cousin for 3 days.  
- **Bandwidth bias:** if user consistently picks shortest variant, boost 5‑min candidates next week (and vice versa).  
- **Timing bias:** favor hour buckets with higher completion.  
- **Friction dampener:** if `frictionIndex > 0.4` for 3 consecutive days → reduce novelty/difficulty for 3 days; surface Coping Kit and pause scoring.  
- **Ritual protection:** don’t replace a streaking ritual; rotate variety around it.

## Analytics Events (privacy‑first)
- `focus.activate` `{ focusId }`  
- `today.shown` `{ templateIds[] }`  
- `today.pick` `{ templateId, variant }`  
- `today.complete|snooze|skip` `{ templateId }`  
- `today.reflect` `{ difficulty }`  
- `week.choice` `{ decision }`  
- `month.accept_blocks` `{ count }`
> Events are queued locally; upload only with explicit consent. No raw note text by default.

## Seeding & Versioning
- Ship seeds: `/SeedContent/milestones_seed.json` and `/SeedContent/actions_seed.json` with `contentVersion`.  
- On launch, run idempotent import: add new templates; never duplicate.  
- Keep `source` on templates (Elaro | partner) for auditability.

## Indices & Retention
- Indices: `ActionInstance(date)`, `ActionInstance(templateId)`, `WeeklySummary(weekStart)`.  
- Retention: allow auto‑purge of notes after N months (default 12) while preserving aggregate Signals.  
- Export/Delete: full export (JSON) and one‑tap delete from Settings.

## SwiftData Sketch (appendix)
```swift
@Model final class FocusArea {
  @Attribute(.unique) var id: UUID
  var name: String
  var active: Bool
  var startedAt: Date
  @Relationship var buildingBlocks: [BuildingBlock]
}

@Model final class BuildingBlock {
  @Attribute(.unique) var id: UUID
  var type: String // microSkill | ritual | support
  var title: String
  var desc: String?
  var tags: [String]
}

@Model final class ActionTemplate {
  @Attribute(.unique) var id: UUID
  var focusId: UUID
  var title: String
  var whyLine: String
  var tags: [String]
  var difficulty: Int
  var variants: [TemplateVariant]
  var contraindications: [String]
  var contentVersion: Int
}

@Model final class TemplateVariant {
  var durationMinutes: Int
  var steps: [String]
}

@Model final class ActionInstance {
  @Attribute(.unique) var id: UUID
  var date: Date
  var templateId: UUID
  var variantDuration: Int
  var status: String // done | snoozed | skipped
  var feltDifficulty: String // light | ok | hard
  var mood: String?
  var note: String?
}

@Model final class WeeklySummary {
  @Attribute(.unique) var id: UUID
  var weekStart: Date
  var winText: String
  var hardText: String
  var suggestedTweak: String // keep | scale_down | scale_up
}
```

## Examples
**ActionTemplate (JSON)**
```json
{
  "id": "A-EMO-001",
  "focusId": "emotion_skills",
  "title": "Name your feeling first, invite theirs",
  "whyLine": "Models language and safety for sharing",
  "tags": ["labeling", "co_regulation"],
  "difficulty": 1,
  "variants": [
    { "durationMinutes": 5,  "steps": ["Say 'I feel… because…'", "Ask 'What’s your feeling?' "] },
    { "durationMinutes": 10, "steps": ["Add a feelings chart" ] }
  ],
  "contraindications": ["skip_if_dysregulated"],
  "contentVersion": 1
}
```

**Cross‑links**  
Product method: `Elaro_scaffold/docs/product/PRODUCT_METHOD_FOCUS_AREA.md`  
Architecture: `/docs/engineering/ARCHITECTURE.md`  
Product brief: `/docs/product/PRODUCT_BRIEF.md`

