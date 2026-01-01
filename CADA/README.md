# CADA - Habit Tracking App

A beautiful iOS habit tracking app with iOS 26-style liquid glass aesthetic, featuring unique visualizations and seamless daily tracking.

## Features

### Habit Types
- **Yes/No** - Simple completion tracking (e.g., "Did I exercise today?")
- **Count** - Track quantities (e.g., glasses of water, pushups)
- **Duration** - Track time spent (e.g., reading, meditation)
- **Measurement** - Track values (e.g., weight, steps)
- **Rating** - Track on a scale (e.g., mood, energy level)

### Unique Visualizations
- **Heat Map** - GitHub-style contribution grid showing activity intensity
- **Streak** - Animated flame showing current and longest streaks
- **Constellation** - Stars form constellations as habits complete
- **Bloom Garden** - Watch flowers grow with consistency
- **Wave Pattern** - Rhythmic waves showing completion patterns
- **Radial Burst** - Rays emanating from center for each day
- **Progress Ring** - Circular progress toward goals
- **Trend Graph** - Line chart showing trends over time
- **Calendar Grid** - Traditional calendar with completion markers
- **Comparison Bar** - Compare current period to previous

### Customization
- Choose from 10 beautiful color themes per habit
- Select from 25+ icons
- Set custom frequencies (daily, weekdays, weekends, weekly, custom days)
- Choose preferred visualization per habit
- Set time frames (week, month, 3 months, 6 months, year, all time)

### Daily Entry
- Smooth daily logging experience
- Push notification reminders at your chosen time
- Quick entry from notification actions
- Log past days if needed

### Widgets
- Small, medium, and large home screen widgets
- Lock screen widgets (circular, rectangular, inline)
- Real-time habit progress display
- Streak indicators

### Social Sharing
- Beautiful share cards in multiple styles
- Customizable what to include (streaks, stats, visualization)
- Direct sharing to social media

## Architecture

```
CADA/
├── CADA/
│   ├── App/
│   │   ├── CADAApp.swift
│   │   └── ContentView.swift
│   ├── Models/
│   │   ├── Habit.swift
│   │   ├── HabitEntry.swift
│   │   └── HabitType.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   ├── Habits/
│   │   ├── Statistics/
│   │   ├── Settings/
│   │   ├── Entry/
│   │   └── Components/
│   ├── Visualizations/
│   │   ├── HeatMapVisualization.swift
│   │   ├── StreakVisualization.swift
│   │   ├── ConstellationVisualization.swift
│   │   ├── BloomGardenVisualization.swift
│   │   ├── WavePatternVisualization.swift
│   │   ├── RadialBurstVisualization.swift
│   │   ├── ProgressRingVisualization.swift
│   │   ├── TrendGraphVisualization.swift
│   │   ├── CalendarGridVisualization.swift
│   │   └── ComparisonBarVisualization.swift
│   ├── Services/
│   │   └── NotificationService.swift
│   ├── Theme/
│   │   └── LiquidGlassTheme.swift
│   └── Resources/
├── CADAWidgets/
│   └── CADAWidgets.swift
└── README.md
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Open `CADA.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on simulator or device

## Technologies

- **SwiftUI** - Modern declarative UI
- **SwiftData** - Data persistence
- **WidgetKit** - Home and lock screen widgets
- **UserNotifications** - Push notifications
- **AppIntents** - Widget configuration

## Design

The app features a liquid glass aesthetic inspired by iOS 26, with:
- Translucent, frosted glass cards
- Animated gradient backgrounds
- Smooth spring animations
- Dynamic glow effects
- Custom tab bar with glass effect

## License

MIT License
