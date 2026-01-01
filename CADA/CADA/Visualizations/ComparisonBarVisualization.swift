import SwiftUI

struct ComparisonBarVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var animationProgress: CGFloat = 0

    private var currentPeriodRate: Double {
        habit.completionRate(timeFrame: timeFrame)
    }

    private var previousPeriodRate: Double {
        let calendar = Calendar.current
        let today = Date()
        let periodDays = timeFrame.days

        guard let previousStart = calendar.date(byAdding: .day, value: -periodDays * 2, to: today),
              let previousEnd = calendar.date(byAdding: .day, value: -periodDays, to: today) else {
            return 0
        }

        var totalDays = 0
        var completedDays = 0
        var currentDate = previousStart

        while currentDate < previousEnd {
            if habit.shouldTrack(on: currentDate) {
                totalDays += 1
                if habit.isCompleted(for: currentDate) {
                    completedDays += 1
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
    }

    private var changePercentage: Double {
        if previousPeriodRate == 0 { return currentPeriodRate > 0 ? 100 : 0 }
        return ((currentPeriodRate - previousPeriodRate) / previousPeriodRate) * 100
    }

    private var changeDirection: ChangeDirection {
        if changePercentage > 5 { return .improved }
        if changePercentage < -5 { return .declined }
        return .stable
    }

    var body: some View {
        VStack(spacing: 24) {
            // Change indicator
            HStack(spacing: 12) {
                Image(systemName: changeDirection.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(changeDirection.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(changeDirection.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(changePercentage >= 0 ? "+" : "")\(Int(changePercentage))% vs last \(timeFrame.displayName.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()
            }

            // Comparison bars
            VStack(spacing: 16) {
                // Current period
                comparisonBar(
                    label: "This \(timeFrame.displayName)",
                    value: currentPeriodRate,
                    isCurrent: true
                )

                // Previous period
                comparisonBar(
                    label: "Last \(timeFrame.displayName)",
                    value: previousPeriodRate,
                    isCurrent: false
                )
            }

            // Detailed stats
            HStack(spacing: 0) {
                statColumn(
                    title: "Current",
                    value: "\(Int(currentPeriodRate * 100))%",
                    detail: "\(currentPeriodEntries) entries",
                    color: habit.color
                )

                Divider()
                    .frame(height: 50)
                    .background(.white.opacity(0.2))

                statColumn(
                    title: "Previous",
                    value: "\(Int(previousPeriodRate * 100))%",
                    detail: "\(previousPeriodEntries) entries",
                    color: .white.opacity(0.5)
                )

                Divider()
                    .frame(height: 50)
                    .background(.white.opacity(0.2))

                statColumn(
                    title: "Difference",
                    value: "\(changePercentage >= 0 ? "+" : "")\(Int(changePercentage))%",
                    detail: changeDirection.subtitle,
                    color: changeDirection.color
                )
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1)) {
                animationProgress = 1
            }
        }
    }

    private func comparisonBar(label: String, value: Double, isCurrent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isCurrent ? .white : .white.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.1))

                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            isCurrent
                                ? LinearGradient(colors: habit.gradient, startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * value * animationProgress)

                    // Shine effect for current period
                    if isCurrent {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: geo.size.width * value * animationProgress, height: geo.size.height / 2)
                    }
                }
            }
            .frame(height: 16)
        }
    }

    private func statColumn(title: String, value: String, detail: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var currentPeriodEntries: Int {
        habit.entries(for: timeFrame).filter { $0.isCompleted }.count
    }

    private var previousPeriodEntries: Int {
        let calendar = Calendar.current
        let today = Date()
        let periodDays = timeFrame.days

        guard let previousStart = calendar.date(byAdding: .day, value: -periodDays * 2, to: today),
              let previousEnd = calendar.date(byAdding: .day, value: -periodDays, to: today) else {
            return 0
        }

        return habit.entries.filter { entry in
            entry.isCompleted && entry.date >= previousStart && entry.date < previousEnd
        }.count
    }
}

enum ChangeDirection {
    case improved
    case declined
    case stable

    var icon: String {
        switch self {
        case .improved: return "arrow.up.circle.fill"
        case .declined: return "arrow.down.circle.fill"
        case .stable: return "equal.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .improved: return .green
        case .declined: return .red
        case .stable: return .blue
        }
    }

    var title: String {
        switch self {
        case .improved: return "Great Progress!"
        case .declined: return "Room for Improvement"
        case .stable: return "Staying Consistent"
        }
    }

    var subtitle: String {
        switch self {
        case .improved: return "Keep it up!"
        case .declined: return "You've got this!"
        case .stable: return "Nice work!"
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        ComparisonBarVisualization(habit: Habit.sampleHabits[0], timeFrame: .week)
            .padding()
    }
}
