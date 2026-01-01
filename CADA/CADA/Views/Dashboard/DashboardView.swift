import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Binding var showingDailyEntry: Bool
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingAddHabit = false

    private var todayProgress: Double {
        guard !habits.isEmpty else { return 0 }
        let completed = habits.filter { $0.isCompleted(for: Date()) }.count
        return Double(completed) / Double(habits.count)
    }

    private var todayCompleted: Int {
        habits.filter { $0.isCompleted(for: Date()) }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Quick Entry Button
                quickEntryButton

                // Today's Progress Card
                todayProgressCard

                // Today's Habits
                todaysHabitsSection

                // Weekly Overview
                weeklyOverviewSection

                // Top Streaks
                topStreaksSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                Text(formattedDate)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                showingAddHabit = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
                    .symbolEffect(.pulse, options: .repeating)
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Quick Entry Button

    private var quickEntryButton: some View {
        Button {
            showingDailyEntry = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "pencil.line")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Log Today's Habits")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(habits.count - todayCompleted) habits remaining")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Progress Card

    private var todayProgressCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(Int(todayProgress * 100))%")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }

            // Progress Ring
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: todayProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1), value: todayProgress)

                VStack(spacing: 4) {
                    Text("\(todayCompleted)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("of \(habits.count) completed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 160)
            .padding(.vertical, 10)

            // Quick Stats
            HStack(spacing: 0) {
                statItem(value: "\(habits.map { $0.currentStreak }.max() ?? 0)", label: "Best Streak")
                Divider().frame(height: 40).background(.white.opacity(0.2))
                statItem(value: "\(Int((habits.map { $0.completionRate(timeFrame: .week) }.reduce(0, +) / max(Double(habits.count), 1)) * 100))%", label: "Weekly Rate")
                Divider().frame(height: 40).background(.white.opacity(0.2))
                statItem(value: "\(habits.map { $0.totalCompletions }.reduce(0, +))", label: "Total Logs")
            }
        }
        .padding(20)
        .glassCard()
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Today's Habits Section

    private var todaysHabitsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Today's Habits")

            if habits.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(habits.prefix(5)) { habit in
                        TodayHabitRow(habit: habit)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))

            Text("No habits yet")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))

            Text("Tap + to create your first habit")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassCard()
    }

    // MARK: - Weekly Overview

    private var weeklyOverviewSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "This Week")

            WeeklyOverviewCard(habits: habits)
        }
    }

    // MARK: - Top Streaks

    private var topStreaksSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Top Streaks")

            LazyVStack(spacing: 12) {
                ForEach(habits.sorted { $0.currentStreak > $1.currentStreak }.prefix(3)) { habit in
                    StreakRow(habit: habit)
                }
            }
        }
    }
}

// MARK: - Today Habit Row

struct TodayHabitRow: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @State private var isCompleted: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            // Completion toggle
            Button {
                toggleCompletion()
            } label: {
                ZStack {
                    Circle()
                        .fill(isCompleted ? habit.color : .white.opacity(0.1))
                        .frame(width: 44, height: 44)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: habit.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(habit.color)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .strikethrough(isCompleted, color: .white.opacity(0.5))

                if let entry = habit.entry(for: Date()), habit.habitType != .boolean {
                    Text(entry.displayValue)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text(habit.habitType.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Spacer()

            // Streak indicator
            if habit.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)

                    Text("\(habit.currentStreak)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(.orange.opacity(0.2))
                }
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
        .onAppear {
            isCompleted = habit.isCompleted(for: Date())
        }
    }

    private func toggleCompletion() {
        withAnimation(.spring(response: 0.3)) {
            isCompleted.toggle()
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let existingEntry = habit.entries.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            existingEntry.booleanValue = isCompleted
            if !isCompleted {
                existingEntry.value = 0
            }
        } else if isCompleted {
            let entry = HabitEntry(date: today, booleanValue: true, habit: habit)
            modelContext.insert(entry)
        }
    }
}

// MARK: - Weekly Overview Card

struct WeeklyOverviewCard: View {
    let habits: [Habit]

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    dayColumn(for: date)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private func dayColumn(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let completionRate = dayCompletionRate(for: date)

        return VStack(spacing: 8) {
            Text(dayAbbreviation(for: date))
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))

            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: completionRate)
                    .stroke(
                        completionRate > 0 ? Color.green : Color.clear,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                Text("\(calendar.component(.day, from: date))")
                    .font(.caption.weight(isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? .white : .white.opacity(0.7))
            }

            Circle()
                .fill(completionRate == 1 ? Color.green : (completionRate > 0 ? Color.orange : Color.white.opacity(0.2)))
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(1).uppercased()
    }

    private func dayCompletionRate(for date: Date) -> Double {
        guard !habits.isEmpty else { return 0 }
        let trackableHabits = habits.filter { $0.shouldTrack(on: date) }
        guard !trackableHabits.isEmpty else { return 0 }
        let completed = trackableHabits.filter { $0.isCompleted(for: date) }.count
        return Double(completed) / Double(trackableHabits.count)
    }
}

// MARK: - Streak Row

struct StreakRow: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: habit.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(habit.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)

                Text("Longest: \(habit.longestStreak) days")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
                    .symbolEffect(.bounce, options: .repeating.speed(0.5))

                Text("\(habit.currentStreak)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text("days")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        DashboardView(showingDailyEntry: .constant(false))
    }
    .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
