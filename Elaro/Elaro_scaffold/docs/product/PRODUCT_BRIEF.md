# Product Brief

_Last updated: 2025‑09‑04_

## Overview
Elaro helps caregivers make small, compassionate moves each day that add up to long‑term growth for their kids. The experience centers on **Focus Areas** (e.g., Independence, Emotion Skills) and a shallow→deep card stack (Today → Week → Month → Season) that keeps daily actions aligned with a family’s “north star.”

**Audience:** primary caregivers (and co‑parents/caregivers) of children ages ~3–12.  
**Platforms:** iOS (initial), later web/Android.  
**Principles:** humane by default, evidence‑aligned, autonomy‑supportive, privacy‑first.

## Vision & North Star
**North Star:** Grow **Autonomy, Competence, and Relatedness** for kids and caregivers. Every recommendation should clearly support one or more of these needs.  
**Method:** Parents select **1–2 Focus Areas**. Daily suggestions and weekly/monthly planning are shaped by:
- **Upward signals:** completions, felt difficulty, notes keywords → weekly tweak → monthly “building blocks.”
- **Downward constraints:** active Focus + building blocks bias daily suggestions and copy (the “why”).

See: `Elaro_scaffold/docs/product/PRODUCT_METHOD_FOCUS_AREA.md` for the full method.

## Users & Jobs to Be Done (JTBD)
1) “Help me know what matters at my child’s age.”  
2) “Give me simple, doable actions today.”  
3) “Show me progress so I stay motivated.”  
4) “Coordinate with my co‑parent/caregivers without friction.”

## Value Proposition
- **Clarity in 15 seconds:** 1–3 tiny, choice‑rich actions for today.  
- **Consistency without guilt:** gentle weekly keep/adjust, monthly plan in 3 tiles.  
- **Trustworthy:** content is human‑authored and explainable; rationale lines show why each suggestion helps.

## Scope (MVP)
### Goals
- Ship a **Today** loop that suggests **2–3 tiny actions** per active Focus based on explainable scoring.  
- Provide a **Weekly Keep/Adjust** decision and a **Monthly Plan** with **3 building blocks** (Micro‑skill, Ritual, Support).  
- Offer clear **rationale lines** and on‑device scoring (privacy‑first).  
- Co‑parent weekly digest (Win • What’s Hard • Tweak) with quick Keep/Adjust.

### Non‑Goals (MVP)
- Cross‑household social graphs or public feeds.  
- Points/badges leaderboards (use **streaks & stories** instead).  
- Multi‑child switching inside the card deck (lives in a top utility bar).  
- Heavy AI dependence; deterministic rules are the baseline.

## Experience Overview
- **Top utility bar:** child chip, deck selector (future), search, bell.  
- **Deck (Focus Area):** Today → Week → Month → Season cards.  
- **Library:** only shows items tagged to active Focus; “Add to Today” in one tap.  
- **Progress:** trends and tiny narratives **by Focus**, not generic points.  
- **Settings/Privacy:** export/delete, notification control, feature flags (hidden).

## Success Metrics (MVP)
- **Daily completion:** ≥60% of days with an active Focus.  
- **Weekly Keep/Adjust participation:** ≥70%.  
- **Monthly acceptance:** ≥80% accept ≥2/3 proposed blocks.  
- **Qualitative:** parent notes mention **less friction** or **more initiative** within 4–6 weeks.  
- **Retention guardrail:** no increase in “overwhelmed” notes during weeks 1–4.

## Risks & Mitigations
- **Overwhelm:** limit to 1–2 active Focus Areas; max 3 actions/day; protect rituals.  
- **Tone misfires:** effort‑praise language bank; never shamey; allow “make it smaller.”  
- **Privacy:** on‑device by default; clear explanations; easy pause/erase; no raw note upload by default.  
- **Cold start:** ship seeded actions per Focus; strong empty states.

## Roadmap (high level)
1) **Milestone A — Today Loop**: deterministic recommender; reflection; basic analytics.  
2) **Milestone B — Weekly/Monthly**: Keep/Adjust; 3 building blocks; digest.  
3) **Milestone C — Co‑parent**: invite, digest voting, shared plan with private notes.  
4) **Milestone D — Insights**: progress narratives, highlight reel; export.  
5) **Milestone E — Assistive AI (optional)**: on‑device summaries; contextual bandit for `SuccessProbability`.

**Cross‑links**  
Product method: `Elaro_scaffold/docs/product/PRODUCT_METHOD_FOCUS_AREA.md`  
Architecture: `/docs/engineering/ARCHITECTURE.md`  


