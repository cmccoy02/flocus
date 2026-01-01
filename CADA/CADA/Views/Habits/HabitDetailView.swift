import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit

    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedVisualization: VisualizationType = .heatMap
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header card
                        headerCard

                        // Time frame selector
                        timeFrameSelector

                        // Visualization selector
                        visualizationSelector

                        // Main visualization
                        visualizationCard

                        // Statistics
                        statisticsSection

                        // Recent entries
                        recentEntriesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Habit", systemImage: "pencil")
                        }

                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share Progress", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button {
                            habit.isArchived.toggle()
                        } label: {
                            Label(
                                habit.isArchived ? "Unarchive" : "Archive",
                                systemImage: habit.isArchived ? "tray.and.arrow.up" : "archivebox"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareHabitView(habit: habit, timeFrame: selectedTimeFrame)
        }
        .onAppear {
            selectedVisualization = habit.preferredVisualization
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: habit.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                .glow(color: habit.color, radius: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text(habit.habitDescription.isEmpty ? habit.habitType.displayName : habit.habitDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()
            }

            Divider()
                .background(.white.opacity(0.2))

            HStack {
                statBadge(
                    icon: "flame.fill",
                    value: "\(habit.currentStreak)",
                    label: "Current",
                    color: .orange
                )

                Divider()
                    .frame(height: 40)
                    .background(.white.opacity(0.2))

                statBadge(
                    icon: "crown.fill",
                    value: "\(habit.longestStreak)",
                    label: "Longest",
                    color: .yellow
                )

                Divider()
                    .frame(height: 40)
                    .background(.white.opacity(0.2))

                statBadge(
                    icon: "checkmark.circle.fill",
                    value: "\(habit.totalCompletions)",
                    label: "Total",
                    color: .green
                )
            }
        }
        .padding(20)
        .glassCard()
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
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
                                        .fill(habit.color.opacity(0.4))
                                        .overlay {
                                            Capsule()
                                                .stroke(habit.color.opacity(0.6), lineWidth: 1)
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

    // MARK: - Visualization Selector

    private var visualizationSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(VisualizationType.allCases, id: \.self) { viz in
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            selectedVisualization = viz
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: viz.icon)
                                .font(.system(size: 20))

                            Text(viz.displayName)
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedVisualization == viz ? .white : .white.opacity(0.5))
                        .frame(width: 70, height: 60)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedVisualization == viz ? habit.color.opacity(0.3) : .white.opacity(0.05))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedVisualization == viz ? habit.color.opacity(0.5) : .white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Visualization Card

    private var visualizationCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(selectedVisualization.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(Int(habit.completionRate(timeFrame: selectedTimeFrame) * 100))% complete")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            visualizationContent
                .frame(height: 240)
        }
        .padding(20)
        .glassCard()
    }

    @ViewBuilder
    private var visualizationContent: some View {
        switch selectedVisualization {
        case .heatMap:
            HeatMapVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .streak:
            StreakVisualization(habit: habit)
        case .progressRing:
            ProgressRingVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .trendGraph:
            TrendGraphVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .constellation:
            ConstellationVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .bloomGarden:
            BloomGardenVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .wavePattern:
            WavePatternVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .radialBurst:
            RadialBurstVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .calendarGrid:
            CalendarGridVisualization(habit: habit, timeFrame: selectedTimeFrame)
        case .comparisonBar:
            ComparisonBarVisualization(habit: habit, timeFrame: selectedTimeFrame)
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Statistics")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Completion Rate",
                    value: "\(Int(habit.completionRate(timeFrame: selectedTimeFrame) * 100))%",
                    subtitle: selectedTimeFrame.displayName,
                    icon: "percent",
                    color: habit.color
                )

                StatCard(
                    title: "Average",
                    value: habit.habitType == .boolean ? "-" : String(format: "%.1f", habit.averageValue),
                    subtitle: habit.goalUnit.isEmpty ? habit.habitType.displayName : habit.goalUnit,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                StatCard(
                    title: "Best Day",
                    value: bestDay,
                    subtitle: "Most completions",
                    icon: "star.fill",
                    color: .yellow
                )

                StatCard(
                    title: "Started",
                    value: daysAgo,
                    subtitle: "days ago",
                    icon: "calendar",
                    color: .green
                )
            }
        }
    }

    private var bestDay: String {
        let calendar = Calendar.current
        var dayCounts: [Int: Int] = [:]

        for entry in habit.entries where entry.isCompleted {
            let weekday = calendar.component(.weekday, from: entry.date)
            dayCounts[weekday, default: 0] += 1
        }

        guard let best = dayCounts.max(by: { $0.value < $1.value }) else { return "-" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let date = calendar.date(from: DateComponents(weekday: best.key)) ?? Date()
        return formatter.string(from: date)
    }

    private var daysAgo: String {
        let days = Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
        return "\(days)"
    }

    // MARK: - Recent Entries Section

    private var recentEntriesSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Recent Entries")

            if habit.entries.isEmpty {
                Text("No entries yet")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .glassCard()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(habit.entries.sorted { $0.date > $1.date }.prefix(10)) { entry in
                        EntryRow(entry: entry, habit: habit)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 16)
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: HabitEntry
    let habit: Habit

    var body: some View {
        HStack {
            Circle()
                .fill(entry.isCompleted ? habit.color : .white.opacity(0.2))
                .frame(width: 10, height: 10)

            Text(formattedDate)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(entry.displayValue)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 12, opacity: 0.08)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: entry.date)
    }
}

#Preview {
    HabitDetailView(habit: Habit.sampleHabits[0])
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
