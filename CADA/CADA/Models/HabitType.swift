import SwiftUI

/// The different types of habits users can track
enum HabitType: String, Codable, CaseIterable, Identifiable {
    case boolean = "boolean"      // Yes/No - Did you complete it?
    case count = "count"          // How many? (pushups, glasses of water)
    case duration = "duration"    // How long? (minutes/hours)
    case measurement = "measurement" // Track a value (weight, steps)
    case rating = "rating"        // Scale of 1-5 or 1-10

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .boolean: return "Yes/No"
        case .count: return "Count"
        case .duration: return "Duration"
        case .measurement: return "Measurement"
        case .rating: return "Rating"
        }
    }

    var icon: String {
        switch self {
        case .boolean: return "checkmark.circle"
        case .count: return "number"
        case .duration: return "clock"
        case .measurement: return "ruler"
        case .rating: return "star"
        }
    }

    var description: String {
        switch self {
        case .boolean: return "Track whether you completed a habit"
        case .count: return "Count occurrences (e.g., pushups, glasses of water)"
        case .duration: return "Track time spent (e.g., reading, meditation)"
        case .measurement: return "Record a value (e.g., weight, steps)"
        case .rating: return "Rate on a scale (e.g., mood, energy level)"
        }
    }

    var examples: [String] {
        switch self {
        case .boolean: return ["Exercise", "Read", "Meditate", "Take vitamins"]
        case .count: return ["Pushups", "Glasses of water", "Pages read"]
        case .duration: return ["Reading time", "Screen time", "Meditation"]
        case .measurement: return ["Weight", "Steps", "Sleep hours"]
        case .rating: return ["Mood", "Energy level", "Productivity"]
        }
    }
}

/// Frequency options for habit tracking
enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "daily"
    case weekly = "weekly"
    case weekdays = "weekdays"
    case weekends = "weekends"
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "Every Day"
        case .weekly: return "Weekly"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .daily: return "calendar"
        case .weekly: return "calendar.badge.clock"
        case .weekdays: return "building.2"
        case .weekends: return "house"
        case .custom: return "slider.horizontal.3"
        }
    }
}

/// Time frame options for visualizations
enum TimeFrame: String, Codable, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case threeMonths = "threeMonths"
    case sixMonths = "sixMonths"
    case year = "year"
    case allTime = "allTime"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .year: return "Year"
        case .allTime: return "All Time"
        }
    }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .year: return 365
        case .allTime: return Int.max
        }
    }
}

/// Available visualization types for habits
enum VisualizationType: String, Codable, CaseIterable, Identifiable {
    case heatMap = "heatMap"
    case streak = "streak"
    case progressRing = "progressRing"
    case trendGraph = "trendGraph"
    case constellation = "constellation"
    case bloomGarden = "bloomGarden"
    case wavePattern = "wavePattern"
    case radialBurst = "radialBurst"
    case calendarGrid = "calendarGrid"
    case comparisonBar = "comparisonBar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .heatMap: return "Heat Map"
        case .streak: return "Streak"
        case .progressRing: return "Progress Ring"
        case .trendGraph: return "Trend Graph"
        case .constellation: return "Constellation"
        case .bloomGarden: return "Bloom Garden"
        case .wavePattern: return "Wave Pattern"
        case .radialBurst: return "Radial Burst"
        case .calendarGrid: return "Calendar Grid"
        case .comparisonBar: return "Comparison"
        }
    }

    var icon: String {
        switch self {
        case .heatMap: return "square.grid.3x3"
        case .streak: return "flame"
        case .progressRing: return "circle.dotted"
        case .trendGraph: return "chart.xyaxis.line"
        case .constellation: return "sparkles"
        case .bloomGarden: return "leaf"
        case .wavePattern: return "waveform.path"
        case .radialBurst: return "rays"
        case .calendarGrid: return "calendar"
        case .comparisonBar: return "chart.bar"
        }
    }

    var description: String {
        switch self {
        case .heatMap: return "GitHub-style contribution grid showing activity intensity"
        case .streak: return "Current and longest streak with animated flames"
        case .progressRing: return "Circular progress indicator for goals"
        case .trendGraph: return "Line chart showing trends over time"
        case .constellation: return "Stars form constellations as habits complete"
        case .bloomGarden: return "Watch your garden grow with consistency"
        case .wavePattern: return "Rhythmic waves showing habit patterns"
        case .radialBurst: return "Radial visualization of daily completion"
        case .calendarGrid: return "Traditional calendar with completion markers"
        case .comparisonBar: return "Compare current period to previous"
        }
    }
}

/// Preset color themes for habits
enum HabitColorTheme: String, Codable, CaseIterable, Identifiable {
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case teal = "teal"
    case indigo = "indigo"
    case mint = "mint"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        case .indigo: return .indigo
        case .mint: return .mint
        }
    }

    var gradient: [Color] {
        switch self {
        case .blue: return [.blue, .cyan]
        case .purple: return [.purple, .pink]
        case .pink: return [.pink, .red.opacity(0.8)]
        case .red: return [.red, .orange]
        case .orange: return [.orange, .yellow]
        case .yellow: return [.yellow, .orange]
        case .green: return [.green, .mint]
        case .teal: return [.teal, .cyan]
        case .indigo: return [.indigo, .purple]
        case .mint: return [.mint, .green]
        }
    }
}
