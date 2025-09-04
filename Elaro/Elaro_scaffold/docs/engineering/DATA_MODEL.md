# Data Model

## Entities
**Child**
- id: UUID (required)
- name: String (required)
- birthdate: Date (optional)
- avatarAssetId: String?

**Milestone**
- id: UUID (required)
- title: String (required)
- ageMin: Int16
- ageMax: Int16
- category: String (enum) — home | selfCare | schoolSkills | lifeSkills
- rationale: String
- tips: Transformable (Array<String>)

**ChildMilestone**
- id: UUID (required)
- childId: UUID (fk)
- milestoneId: UUID (fk)
- stage: String (enum) — introduced | practicing | independent
- notes: String?
- createdAt: Date
- updatedAt: Date

**RoutineEntry**
- id: UUID (required)
- childMilestoneId: UUID (fk)
- date: Date
- completed: Bool

## Derived
- Progress % per child = independent_count / tracked_count
- Streaks = consecutive routine entries for milestones in `practicing`
