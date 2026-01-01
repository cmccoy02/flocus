import SwiftUI
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var habitDescription: String
    var icon: String
    var colorThemeRaw: String
    var habitTypeRaw: String
    var frequencyRaw: String
    var preferredVisualizationRaw: String

    // Goal configuration
    var goalValue: Double
    var goalUnit: String
    var ratingScale: Int // For rating type: 5 or 10

    // Notification settings
    var notificationEnabled: Bool
    var notificationTime: Date

    // Custom days for custom frequency
    var customDays: [Int] // 0 = Sunday, 6 = Saturday

    // Metadata
    var createdAt: Date
    var isArchived: Bool
    var sortOrder: Int

    // Relationship to entries
    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    var entries: [HabitEntry]

    // Computed properties
    var colorTheme: HabitColorTheme {
        get { HabitColorTheme(rawValue: colorThemeRaw) ?? .blue }
        set { colorThemeRaw = newValue.rawValue }
    }

    var habitType: HabitType {
        get { HabitType(rawValue: habitTypeRaw) ?? .boolean }
        set { habitTypeRaw = newValue.rawValue }
    }

    var frequency: HabitFrequency {
        get { HabitFrequency(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }

    var preferredVisualization: VisualizationType {
        get { VisualizationType(rawValue: preferredVisualizationRaw) ?? .heatMap }
        set { preferredVisualizationRaw = newValue.rawValue }
    }

    var color: Color {
        colorTheme.color
    }

    var gradient: [Color] {
        colorTheme.gradient
    }

    init(
        name: String,
        description: String = "",
        icon: String = "checkmark.circle",
        colorTheme: HabitColorTheme = .blue,
        habitType: HabitType = .boolean,
        frequency: HabitFrequency = .daily,
        preferredVisualization: VisualizationType = .heatMap,
        goalValue: Double = 1.0,
        goalUnit: String = "",
        ratingScale: Int = 5,
        notificationEnabled: Bool = true,
        notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date(),
        customDays: [Int] = []
    ) {
        self.id = UUID()
        self.name = name
        self.habitDescription = description
        self.icon = icon
        self.colorThemeRaw = colorTheme.rawValue
        self.habitTypeRaw = habitType.rawValue
        self.frequencyRaw = frequency.rawValue
        self.preferredVisualizationRaw = preferredVisualization.rawValue
        self.goalValue = goalValue
        self.goalUnit = goalUnit
        self.ratingScale = ratingScale
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.customDays = customDays
        self.createdAt = Date()
        self.isArchived = false
        self.sortOrder = 0
        self.entries = []
    }

    // MARK: - Statistics Calculations

    func entry(for date: Date) -> HabitEntry? {
        let calendar = Calendar.current
        return entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func hasEntry(for date: Date) -> Bool {
        entry(for: date) != nil
    }

    func isCompleted(for date: Date) -> Bool {
        guard let entry = entry(for: date) else { return false }
        return entry.isCompleted
    }

    func completionPercentage(for date: Date) -> Double {
        guard let entry = entry(for: date) else { return 0 }
        return entry.completionPercentage(goal: goalValue)
    }

    /// Calculate current streak
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Check if today is completed, if not start from yesterday
        if !isCompleted(for: currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }

        while isCompleted(for: currentDate) && shouldTrack(on: currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!

            // Skip days that shouldn't be tracked
            while !shouldTrack(on: currentDate) && currentDate > (entries.map { $0.date }.min() ?? Date.distantPast) {
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            }
        }

        return streak
    }

    /// Calculate longest streak ever
    var longestStreak: Int {
        guard !entries.isEmpty else { return 0 }

        let sortedEntries = entries
            .filter { $0.isCompleted && shouldTrack(on: $0.date) }
            .sorted { $0.date < $1.date }

        guard !sortedEntries.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        let calendar = Calendar.current

        for i in 1..<sortedEntries.count {
            let daysBetween = calendar.dateComponents([.day], from: sortedEntries[i-1].date, to: sortedEntries[i].date).day ?? 0

            if daysBetween == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return max(longest, current)
    }

    /// Completion rate for a given time frame
    func completionRate(timeFrame: TimeFrame) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date

        if timeFrame == .allTime {
            startDate = createdAt
        } else {
            startDate = calendar.date(byAdding: .day, value: -timeFrame.days, to: endDate)!
        }

        var totalDays = 0
        var completedDays = 0
        var currentDate = startDate

        while currentDate <= endDate {
            if shouldTrack(on: currentDate) {
                totalDays += 1
                if isCompleted(for: currentDate) {
                    completedDays += 1
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
    }

    /// Total completions count
    var totalCompletions: Int {
        entries.filter { $0.isCompleted }.count
    }

    /// Average value for count/measurement/rating habits
    var averageValue: Double {
        let validEntries = entries.filter { $0.value > 0 }
        guard !validEntries.isEmpty else { return 0 }
        return validEntries.reduce(0) { $0 + $1.value } / Double(validEntries.count)
    }

    /// Check if habit should be tracked on a specific day
    func shouldTrack(on date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date) - 1 // 0 = Sunday

        switch frequency {
        case .daily:
            return true
        case .weekdays:
            return weekday >= 1 && weekday <= 5
        case .weekends:
            return weekday == 0 || weekday == 6
        case .weekly:
            // Track on the same day as creation
            let creationWeekday = calendar.component(.weekday, from: createdAt) - 1
            return weekday == creationWeekday
        case .custom:
            return customDays.contains(weekday)
        }
    }

    /// Get entries for a time frame
    func entries(for timeFrame: TimeFrame) -> [HabitEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date

        if timeFrame == .allTime {
            return entries.sorted { $0.date < $1.date }
        } else {
            startDate = calendar.date(byAdding: .day, value: -timeFrame.days, to: endDate)!
        }

        return entries
            .filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date < $1.date }
    }

    /// Get completion data for heat map (last year by default)
    func heatMapData(weeks: Int = 52) -> [[Double]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the start of the week for today
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1 // Sunday = 1
        let endOfCurrentWeek = calendar.date(byAdding: .day, value: 7 - weekday, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -(weeks * 7) + 1, to: endOfCurrentWeek)!

        var data: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 7), count: weeks)

        for week in 0..<weeks {
            for day in 0..<7 {
                let dayOffset = week * 7 + day
                let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!

                if date <= today && date >= createdAt {
                    data[week][day] = completionPercentage(for: date)
                } else {
                    data[week][day] = -1 // Indicates no data
                }
            }
        }

        return data
    }
}

// MARK: - Sample Data

extension Habit {
    static var sampleHabits: [Habit] {
        [
            {
                let habit = Habit(
                    name: "Morning Meditation",
                    description: "Start the day with clarity",
                    icon: "brain.head.profile",
                    colorTheme: .purple,
                    habitType: .duration,
                    frequency: .daily,
                    preferredVisualization: .streak,
                    goalValue: 10,
                    goalUnit: "minutes"
                )
                return habit
            }(),
            {
                let habit = Habit(
                    name: "Exercise",
                    description: "Stay active and healthy",
                    icon: "figure.run",
                    colorTheme: .green,
                    habitType: .boolean,
                    frequency: .weekdays,
                    preferredVisualization: .heatMap
                )
                return habit
            }(),
            {
                let habit = Habit(
                    name: "Read",
                    description: "Expand your mind",
                    icon: "book",
                    colorTheme: .blue,
                    habitType: .count,
                    frequency: .daily,
                    preferredVisualization: .trendGraph,
                    goalValue: 30,
                    goalUnit: "pages"
                )
                return habit
            }(),
            {
                let habit = Habit(
                    name: "Water Intake",
                    description: "Stay hydrated",
                    icon: "drop",
                    colorTheme: .teal,
                    habitType: .count,
                    frequency: .daily,
                    preferredVisualization: .progressRing,
                    goalValue: 8,
                    goalUnit: "glasses"
                )
                return habit
            }(),
            {
                let habit = Habit(
                    name: "Daily Mood",
                    description: "Track your emotional wellbeing",
                    icon: "face.smiling",
                    colorTheme: .orange,
                    habitType: .rating,
                    frequency: .daily,
                    preferredVisualization: .wavePattern,
                    ratingScale: 5
                )
                return habit
            }()
        ]
    }
}
