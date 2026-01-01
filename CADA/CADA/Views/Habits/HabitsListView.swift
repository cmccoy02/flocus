import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) private var allHabits: [Habit]

    @State private var searchText = ""
    @State private var selectedFilter: HabitFilter = .active
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?

    enum HabitFilter: String, CaseIterable {
        case active = "Active"
        case archived = "Archived"
        case all = "All"
    }

    private var filteredHabits: [Habit] {
        var habits: [Habit]

        switch selectedFilter {
        case .active:
            habits = allHabits.filter { !$0.isArchived }
        case .archived:
            habits = allHabits.filter { $0.isArchived }
        case .all:
            habits = allHabits
        }

        if !searchText.isEmpty {
            habits = habits.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return habits
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Search bar
                searchBar

                // Filter pills
                filterPills

                // Habits list
                if filteredHabits.isEmpty {
                    emptyStateView
                } else {
                    habitsGrid
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Habits")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text("\(allHabits.filter { !$0.isArchived }.count) active habits")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Button {
                showingAddHabit = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.5))

            TextField("Search habits", text: $searchText)
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                }
        }
    }

    // MARK: - Filter Pills

    private var filterPills: some View {
        HStack(spacing: 10) {
            ForEach(HabitFilter.allCases, id: \.self) { filter in
                FilterPill(
                    title: filter.rawValue,
                    isSelected: selectedFilter == filter
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - Habits Grid

    private var habitsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(filteredHabits) { habit in
                HabitCard(habit: habit)
                    .onTapGesture {
                        selectedHabit = habit
                    }
                    .contextMenu {
                        Button {
                            selectedHabit = habit
                        } label: {
                            Label("View Details", systemImage: "info.circle")
                        }

                        Button {
                            habit.isArchived.toggle()
                        } label: {
                            Label(
                                habit.isArchived ? "Unarchive" : "Archive",
                                systemImage: habit.isArchived ? "tray.and.arrow.up" : "archivebox"
                            )
                        }

                        Divider()

                        Button(role: .destructive) {
                            deleteHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedFilter == .archived ? "archivebox" : "list.bullet.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.3))

            VStack(spacing: 8) {
                Text(selectedFilter == .archived ? "No archived habits" : "No habits found")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                Text(selectedFilter == .archived
                     ? "Archived habits will appear here"
                     : "Create your first habit to get started")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            if selectedFilter != .archived {
                Button {
                    showingAddHabit = true
                } label: {
                    Text("Create Habit")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .buttonStyle(FrostedButtonStyle(color: .blue))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.08))
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(isSelected ? 0.3 : 0.1), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Habit Card

struct HabitCard: View {
    let habit: Habit
    @State private var isPressed = false

    private var todayCompleted: Bool {
        habit.isCompleted(for: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: habit.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }

                Spacer()

                if todayCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
            }

            // Name and type
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(habit.habitType.displayName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Stats row
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Streak")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(habit.completionRate(timeFrame: .week) * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("This week")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Mini heat map (last 7 days)
            MiniHeatMap(habit: habit)
        }
        .padding(16)
        .frame(height: 180)
        .glassCard(cornerRadius: 20)
        .overlay {
            if habit.isArchived {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.4))
                    .overlay {
                        Text("Archived")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
            }
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Mini Heat Map

struct MiniHeatMap: View {
    let habit: Habit

    private var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(last7Days, id: \.self) { date in
                let completion = habit.completionPercentage(for: date)
                RoundedRectangle(cornerRadius: 3)
                    .fill(colorForCompletion(completion))
                    .frame(height: 8)
            }
        }
    }

    private func colorForCompletion(_ completion: Double) -> Color {
        if completion <= 0 {
            return .white.opacity(0.1)
        } else if completion < 0.5 {
            return habit.color.opacity(0.3)
        } else if completion < 1.0 {
            return habit.color.opacity(0.6)
        } else {
            return habit.color
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        HabitsListView()
    }
    .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
