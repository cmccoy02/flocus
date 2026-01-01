import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]

    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedHabit: Habit?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Time frame selector
                timeFrameSelector

                // Overall stats
                overallStatsSection

                // Habit comparison
                habitComparisonSection

                // Trends
                trendsSection

                // Achievement badges
                achievementsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Statistics")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text("Track your progress over time")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Time Frame Selector

    private var timeFrameSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TimeFrame.allCases, id: \.self) { frame in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTimeFrame = frame
                        }
                    } label: {
                        Text(frame.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedTimeFrame == frame ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if selectedTimeFrame == frame {
                                    Capsule()
                                        .fill(.blue.opacity(0.4))
                                        .overlay {
                                            Capsule()
                                                .stroke(.blue.opacity(0.6), lineWidth: 1)
                                        }
                                } else {
                                    Capsule()
                                        .fill(.white.opacity(0.08))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Overall Stats

    private var overallStatsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Overview")

            VStack(spacing: 16) {
                // Main completion rate
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.1), lineWidth: 16)
                            .frame(width: 140, height: 140)

                        Circle()
                            .trim(from: 0, to: overallCompletionRate)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text("\(Int(overallCompletionRate * 100))%")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Completion")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.vertical, 10)
                }

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    OverviewStatCard(
                        title: "Total Habits",
                        value: "\(habits.count)",
                        icon: "list.bullet",
                        color: .blue
                    )

                    OverviewStatCard(
                        title: "Active Streak",
                        value: "\(maxCurrentStreak)",
                        icon: "flame.fill",
                        color: .orange
                    )

                    OverviewStatCard(
                        title: "Total Entries",
                        value: "\(totalEntries)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    OverviewStatCard(
                        title: "Best Rate",
                        value: "\(Int(bestHabitRate * 100))%",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
            }
            .padding(20)
            .glassCard()
        }
    }

    private var overallCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        return habits.map { $0.completionRate(timeFrame: selectedTimeFrame) }.reduce(0, +) / Double(habits.count)
    }

    private var maxCurrentStreak: Int {
        habits.map { $0.currentStreak }.max() ?? 0
    }

    private var totalEntries: Int {
        habits.flatMap { $0.entries }.count
    }

    private var bestHabitRate: Double {
        habits.map { $0.completionRate(timeFrame: selectedTimeFrame) }.max() ?? 0
    }

    // MARK: - Habit Comparison

    private var habitComparisonSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Habit Comparison")

            VStack(spacing: 12) {
                ForEach(habits.sorted { $0.completionRate(timeFrame: selectedTimeFrame) > $1.completionRate(timeFrame: selectedTimeFrame) }) { habit in
                    HabitComparisonRow(habit: habit, timeFrame: selectedTimeFrame)
                }
            }
            .padding(16)
            .glassCard()
        }
    }

    // MARK: - Trends

    private var trendsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Weekly Trends")

            WeeklyTrendChart(habits: habits)
                .frame(height: 200)
                .padding(20)
                .glassCard()
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Achievements")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AchievementBadge(
                    icon: "flame.fill",
                    title: "7 Day Streak",
                    isUnlocked: maxCurrentStreak >= 7,
                    color: .orange
                )

                AchievementBadge(
                    icon: "star.fill",
                    title: "Perfect Week",
                    isUnlocked: hasPerfectWeek,
                    color: .yellow
                )

                AchievementBadge(
                    icon: "trophy.fill",
                    title: "30 Day Streak",
                    isUnlocked: habits.map { $0.longestStreak }.max() ?? 0 >= 30,
                    color: .purple
                )

                AchievementBadge(
                    icon: "crown.fill",
                    title: "100 Entries",
                    isUnlocked: totalEntries >= 100,
                    color: .blue
                )

                AchievementBadge(
                    icon: "bolt.fill",
                    title: "5 Habits",
                    isUnlocked: habits.count >= 5,
                    color: .green
                )

                AchievementBadge(
                    icon: "heart.fill",
                    title: "Consistent",
                    isUnlocked: overallCompletionRate >= 0.8,
                    color: .pink
                )
            }
            .padding(16)
            .glassCard()
        }
    }

    private var hasPerfectWeek: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let trackableHabits = habits.filter { $0.shouldTrack(on: date) }
            let completedHabits = trackableHabits.filter { $0.isCompleted(for: date) }

            if completedHabits.count != trackableHabits.count && !trackableHabits.isEmpty {
                return false
            }
        }
        return true
    }
}

// MARK: - Overview Stat Card

struct OverviewStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.05))
        }
    }
}

// MARK: - Habit Comparison Row

struct HabitComparisonRow: View {
    let habit: Habit
    let timeFrame: TimeFrame

    private var completionRate: Double {
        habit.completionRate(timeFrame: timeFrame)
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(habit.color)
                .frame(width: 12, height: 12)

            Text(habit.name)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * completionRate)
                }
            }
            .frame(width: 100, height: 8)

            Text("\(Int(completionRate * 100))%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Weekly Trend Chart

struct WeeklyTrendChart: View {
    let habits: [Habit]

    private var weeklyData: [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return 0 }
            let trackableHabits = habits.filter { $0.shouldTrack(on: date) }
            guard !trackableHabits.isEmpty else { return 0 }
            let completedCount = trackableHabits.filter { $0.isCompleted(for: date) }.count
            return Double(completedCount) / Double(trackableHabits.count)
        }
    }

    private var dayLabels: [String] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).reversed().map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return "" }
            return formatter.string(from: date)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: max(4, 120 * value))

                        Text(dayLabels[index])
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)

            // Average indicator
            HStack {
                Text("Average this week:")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Text("\(Int((weeklyData.reduce(0, +) / 7) * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : .white.opacity(0.05))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? color : .white.opacity(0.2))
            }

            Text(title)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? .white : .white.opacity(0.3))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        StatisticsView()
    }
    .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
