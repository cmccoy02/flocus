import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habits: [HabitSnapshot]
    let configuration: ConfigurationAppIntent
}

struct HabitSnapshot: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let currentStreak: Int
    let isCompletedToday: Bool
    let completionRate: Double
}

// MARK: - App Intent Configuration

import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "CADA Widget"
    static var description = IntentDescription("Track your habits at a glance")

    @Parameter(title: "Show Streaks")
    var showStreaks: Bool

    init() {
        showStreaks = true
    }

    init(showStreaks: Bool) {
        self.showStreaks = showStreaks
    }
}

// MARK: - Timeline Provider

struct CADAWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habits: sampleHabits,
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habits: sampleHabits,
            configuration: configuration
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HabitWidgetEntry> {
        // In a real app, fetch from shared container/SwiftData
        let entry = HabitWidgetEntry(
            date: Date(),
            habits: sampleHabits,
            configuration: configuration
        )

        // Refresh at midnight
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    private var sampleHabits: [HabitSnapshot] {
        [
            HabitSnapshot(id: UUID(), name: "Meditation", icon: "brain.head.profile", colorHex: "9b59b6", currentStreak: 12, isCompletedToday: true, completionRate: 0.85),
            HabitSnapshot(id: UUID(), name: "Exercise", icon: "figure.run", colorHex: "27ae60", currentStreak: 5, isCompletedToday: false, completionRate: 0.72),
            HabitSnapshot(id: UUID(), name: "Reading", icon: "book", colorHex: "3498db", currentStreak: 8, isCompletedToday: true, completionRate: 0.68),
            HabitSnapshot(id: UUID(), name: "Water", icon: "drop", colorHex: "1abc9c", currentStreak: 3, isCompletedToday: false, completionRate: 0.55)
        ]
    }
}

// MARK: - Widget Views

struct CADAWidgetEntryView: View {
    var entry: HabitWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(habits: entry.habits, showStreaks: entry.configuration.showStreaks)
        case .systemMedium:
            MediumWidgetView(habits: entry.habits, showStreaks: entry.configuration.showStreaks)
        case .systemLarge:
            LargeWidgetView(habits: entry.habits, showStreaks: entry.configuration.showStreaks)
        case .accessoryCircular:
            CircularAccessoryView(habit: entry.habits.first)
        case .accessoryRectangular:
            RectangularAccessoryView(habits: entry.habits)
        case .accessoryInline:
            InlineAccessoryView(habits: entry.habits)
        default:
            SmallWidgetView(habits: entry.habits, showStreaks: entry.configuration.showStreaks)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let habits: [HabitSnapshot]
    let showStreaks: Bool

    private var completedToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("CADA")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                if showStreaks, let topStreak = habits.max(by: { $0.currentStreak < $1.currentStreak }) {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(topStreak.currentStreak)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }

            Spacer()

            // Progress
            VStack(alignment: .leading, spacing: 4) {
                Text("\(completedToday)/\(habits.count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("habits today")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Mini indicators
            HStack(spacing: 4) {
                ForEach(habits.prefix(4)) { habit in
                    Circle()
                        .fill(habit.isCompletedToday ? Color(hex: habit.colorHex) ?? .blue : .white.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let habits: [HabitSnapshot]
    let showStreaks: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Today's Habits")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Habits grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(habits.prefix(4)) { habit in
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(habit.isCompletedToday
                                    ? (Color(hex: habit.colorHex) ?? .blue)
                                    : .white.opacity(0.1))
                                .frame(width: 32, height: 32)

                            if habit.isCompletedToday {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Image(systemName: habit.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            if showStreaks && habit.currentStreak > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.orange)
                                    Text("\(habit.currentStreak)")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.05))
                    }
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let habits: [HabitSnapshot]
    let showStreaks: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CADA")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count))
                        .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count) * 100))%")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
            }

            // Habits list
            VStack(spacing: 8) {
                ForEach(habits) { habit in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(habit.isCompletedToday
                                    ? (Color(hex: habit.colorHex) ?? .blue)
                                    : .white.opacity(0.1))
                                .frame(width: 40, height: 40)

                            if habit.isCompletedToday {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Image(systemName: habit.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)

                            Text("\(Int(habit.completionRate * 100))% completion rate")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        if showStreaks && habit.currentStreak > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text("\(habit.currentStreak)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.orange.opacity(0.2)))
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.05))
                    }
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Lock Screen Widgets

struct CircularAccessoryView: View {
    let habit: HabitSnapshot?

    var body: some View {
        if let habit = habit {
            ZStack {
                AccessoryWidgetBackground()

                VStack(spacing: 2) {
                    Image(systemName: habit.icon)
                        .font(.system(size: 16))

                    if habit.currentStreak > 0 {
                        Text("\(habit.currentStreak)")
                            .font(.caption2.weight(.bold))
                    }
                }
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "checkmark.circle")
            }
        }
    }
}

struct RectangularAccessoryView: View {
    let habits: [HabitSnapshot]

    private var completedToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Habits")
                    .font(.caption.weight(.semibold))

                Text("\(completedToday)/\(habits.count)")
                    .font(.title3.weight(.bold))
            }

            Spacer()

            if let topStreak = habits.max(by: { $0.currentStreak < $1.currentStreak }), topStreak.currentStreak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                    Text("\(topStreak.currentStreak)")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct InlineAccessoryView: View {
    let habits: [HabitSnapshot]

    private var completedToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var body: some View {
        Text("Habits: \(completedToday)/\(habits.count) done")
    }
}

// MARK: - Widget Configuration

@main
struct CADAWidgets: Widget {
    let kind: String = "CADAWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: CADAWidgetProvider()
        ) { entry in
            CADAWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CADA Habits")
        .description("Track your daily habits at a glance")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CADAWidgets()
} timeline: {
    HabitWidgetEntry(date: Date(), habits: [
        HabitSnapshot(id: UUID(), name: "Meditation", icon: "brain.head.profile", colorHex: "9b59b6", currentStreak: 12, isCompletedToday: true, completionRate: 0.85),
        HabitSnapshot(id: UUID(), name: "Exercise", icon: "figure.run", colorHex: "27ae60", currentStreak: 5, isCompletedToday: false, completionRate: 0.72)
    ], configuration: ConfigurationAppIntent())
}

#Preview("Medium", as: .systemMedium) {
    CADAWidgets()
} timeline: {
    HabitWidgetEntry(date: Date(), habits: [
        HabitSnapshot(id: UUID(), name: "Meditation", icon: "brain.head.profile", colorHex: "9b59b6", currentStreak: 12, isCompletedToday: true, completionRate: 0.85),
        HabitSnapshot(id: UUID(), name: "Exercise", icon: "figure.run", colorHex: "27ae60", currentStreak: 5, isCompletedToday: false, completionRate: 0.72),
        HabitSnapshot(id: UUID(), name: "Reading", icon: "book", colorHex: "3498db", currentStreak: 8, isCompletedToday: true, completionRate: 0.68),
        HabitSnapshot(id: UUID(), name: "Water", icon: "drop", colorHex: "1abc9c", currentStreak: 3, isCompletedToday: false, completionRate: 0.55)
    ], configuration: ConfigurationAppIntent())
}
