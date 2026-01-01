import SwiftUI
import SwiftData

@Model
final class HabitEntry {
    var id: UUID
    var date: Date

    // Value storage
    var booleanValue: Bool
    var value: Double
    var notes: String

    // Relationship to habit
    var habit: Habit?

    // Computed completion status
    var isCompleted: Bool {
        guard let habit = habit else { return booleanValue }

        switch habit.habitType {
        case .boolean:
            return booleanValue
        case .count, .measurement, .duration:
            return value >= habit.goalValue
        case .rating:
            return value > 0
        }
    }

    init(
        date: Date = Date(),
        booleanValue: Bool = false,
        value: Double = 0,
        notes: String = "",
        habit: Habit? = nil
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.booleanValue = booleanValue
        self.value = value
        self.notes = notes
        self.habit = habit
    }

    /// Returns completion percentage based on goal
    func completionPercentage(goal: Double) -> Double {
        guard let habit = habit else {
            return booleanValue ? 1.0 : 0.0
        }

        switch habit.habitType {
        case .boolean:
            return booleanValue ? 1.0 : 0.0
        case .count, .measurement, .duration:
            return min(value / goal, 1.0)
        case .rating:
            return value / Double(habit.ratingScale)
        }
    }

    /// Display value formatted appropriately
    var displayValue: String {
        guard let habit = habit else {
            return booleanValue ? "Done" : "Not done"
        }

        switch habit.habitType {
        case .boolean:
            return booleanValue ? "Completed" : "Not completed"
        case .count:
            return "\(Int(value)) \(habit.goalUnit)"
        case .duration:
            return formatDuration(value)
        case .measurement:
            return String(format: "%.1f \(habit.goalUnit)", value)
        case .rating:
            return "\(Int(value))/\(habit.ratingScale)"
        }
    }

    private func formatDuration(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins) min"
    }
}

// MARK: - Sample Entries Generator

extension HabitEntry {
    static func generateSampleEntries(for habit: Habit, days: Int = 90) -> [HabitEntry] {
        let calendar = Calendar.current
        var entries: [HabitEntry] = []

        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            // Skip if habit shouldn't be tracked on this day
            guard habit.shouldTrack(on: date) else { continue }

            // Random completion with higher chance for recent days
            let completionChance = 0.5 + (Double(days - dayOffset) / Double(days)) * 0.3
            let completed = Double.random(in: 0...1) < completionChance

            if completed {
                let entry = HabitEntry(date: date, habit: habit)

                switch habit.habitType {
                case .boolean:
                    entry.booleanValue = true
                case .count:
                    entry.value = Double.random(in: (habit.goalValue * 0.5)...(habit.goalValue * 1.3))
                case .duration:
                    entry.value = Double.random(in: (habit.goalValue * 0.7)...(habit.goalValue * 1.2))
                case .measurement:
                    entry.value = Double.random(in: (habit.goalValue * 0.9)...(habit.goalValue * 1.1))
                case .rating:
                    entry.value = Double(Int.random(in: 1...habit.ratingScale))
                }

                entries.append(entry)
            }
        }

        return entries
    }
}
