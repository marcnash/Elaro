# Elaro - Child Development Tracking App

A SwiftUI-based iOS app that helps caregivers make small, compassionate moves each day that add up to long-term growth for their kids. Built with SwiftData for modern data persistence and designed with evidence-based parenting principles centered on Focus Areas and autonomy-supportive interactions.

## Overview

Elaro centers on **Focus Areas** (e.g., Independence, Emotion Skills) and a shallow-to-deep card stack (Today → Week → Month → Season) that keeps daily actions aligned with a family's "north star." The app emphasizes choice-rich interactions and supports the three fundamental psychological needs: **Autonomy**, **Competence**, and **Relatedness**.

## Architecture

### Core Technologies
- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Apple's new data persistence framework
- **iOS 17+** - Latest iOS features and capabilities

### Project Structure
```
Elaro/
├── Models.swift                    # Core SwiftData models
├── Models+Behavior.swift          # Behavior-specific models
├── ElaroApp.swift                 # App entry point and configuration
├── RootView.swift                 # Main tab navigation
├── ChecklistScreen.swift          # Primary milestone tracking
├── ProgressOverviewScreen.swift   # Visual progress rings
├── WeeklySummaryScreen.swift      # Weekly progress statistics
├── SettingsScreen.swift           # Focus modes and child management
├── BehaviorPlanPanel.swift        # Behavior plan sub-steps
├── FocusModeTileGrid.swift        # Tile-based focus mode selection
├── FlowChipsGrid.swift            # Generic chip selection interface
└── Seed.swift                     # Initial data seeding
```

## Key Features

### Focus Area System
- **1-2 active Focus Areas** to avoid overwhelm
- **Today Loop**: 2-3 tiny, choice-rich actions per active Focus
- **Weekly Keep/Adjust**: Gentle weekly decision with rationale
- **Monthly Plan**: 3 building blocks (Micro-skill, Ritual, Support)
- **Seasonal Planning**: Quarterly reflection and trajectory

### Milestone Tracking
- **Category-based organization** (Home, Self Care, School, Social, Other)
- **Stage progression** (Introduced → Practicing → Independent)
- **Weekly tracking** with date-based progress records
- **Notes system** for observations and insights

### Behavior Management
- **Template-based behavior plans** for specific milestones
- **Weekly plan instances** with step-by-step tracking
- **Checkbox interface** for behavior step completion
- **Automatic plan creation** when milestones are selected

### Progress Visualization
- **Progress Overview**: Ring-based visual representation by category
- **Weekly Summary**: Statistical breakdown of weekly achievements
- **Independent progress tracking** for each milestone category
- **Real-time updates** as stages change

### Child Management
- **Multiple child support** with individual profiles
- **Birthdate tracking** for age-appropriate milestone display
- **Child switching** via dropdown menu
- **Individual progress tracking** per child

## User Experience

### Design Principles
- **Choice-rich interactions** - Always offer options, never pressure
- **Effort-focused language** - Praise process, not traits
- **Emotional integration** - Support co-regulation and emotional awareness
- **Calm is contagious** - Non-anxious stance, avoid shame-based messaging

### Accessibility
- **Dynamic Type** support throughout
- **VoiceOver** compatibility with proper labels
- **44pt touch targets** for easy interaction
- **Motion-reduced animations** for sensitivity
- **Color not sole carrier** of meaning

## Development

### Requirements
- **Xcode 15+**
- **iOS 17+** deployment target
- **Swift 5.9+**

### Setup
1. Clone the repository
2. Open `Elaro.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device

### Data Models
The app uses SwiftData with the following core models:
- `Milestone` - Developmental milestones with categories and stages
- `ChildProfile` - Child information and birthdate
- `MilestoneProgress` - Weekly progress tracking per milestone
- `AppSettings` - User preferences and focus modes
- `BehaviorPlanTemplate` - Behavior plan templates
- `BehaviorStepTemplate` - Individual steps within behavior plans
- `BehaviorPlanProgress` - Weekly behavior plan instances
- `BehaviorStepProgress` - Individual step completion tracking

## Product Method

### Focus Area Methodology
Elaro implements a sophisticated **Focus Area** system based on evidence-based parenting principles. This methodology guides families through developmental themes with a layered approach from daily actions to seasonal planning.

**Key Components:**
- **North Star**: Support Autonomy, Competence, and Relatedness
- **Layered Cards**: Today → Week → Month → Season progression
- **Two-way Flow**: Daily actions inform long-term planning, long-term themes guide daily choices
- **Choice-rich Design**: Always offer 2-3 options, never pressure

**[Read the Complete Product Method Specification →](./Elaro_scaffold/docs/product/PODUCT_METHOD_FOCUS_AREA.md)**

The specification covers:
- Focus Area deck structure (shallow → deep)
- Feedback loops and adaptation rules
- Success criteria and anti-patterns
- Privacy-first analytics approach
- Accessibility and inclusion requirements

## Success Metrics

### Quantitative Targets
- **Daily**: ≥60% of days with at least one action completed in an active Focus
- **Weekly**: ≥70% of weeks with a Keep/Adjust decision
- **Monthly**: ≥80% accept ≥2 of 3 auto-proposed building blocks

### Qualitative Indicators
- Notes mention less friction or more initiative within 4–6 weeks
- Increased parent confidence in supporting child development
- More choice-rich interactions in daily routines

## Privacy & Security

- **On-device computation** by default
- **Minimal child data** (first name + age band only)
- **Clear explanations** for all suggestions ("Because... therefore we suggest...")
- **User controls** to pause learning, clear history, export/delete data
- **No tracking** of sensitive behavioral data

## Future Enhancements

### Planned Features
- **Crisis Flow** - Special handling for high-stress periods
- **Co-Parent Digest** - Weekly summaries for multiple caregivers
- **Focus Area Libraries** - Expanded template collections
- **Seasonal Planning** - Quarterly reflection and planning cycles

### Technical Improvements
- **Offline-first** data synchronization
- **Advanced analytics** with privacy protection
- **Custom milestone creation** by families
- **Export capabilities** for sharing with professionals

## License

This project is part of a development scaffold for child development tracking applications. Please refer to the project documentation for usage guidelines and licensing information.

## Contributing

This is a development scaffold. For contributions or questions about the methodology, please refer to the product documentation in the `Elaro_scaffold/docs/` directory.

---

*Built for families supporting child development through evidence-based, choice-rich interactions.*
