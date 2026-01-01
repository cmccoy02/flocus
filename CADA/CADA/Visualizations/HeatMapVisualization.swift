import SwiftUI

struct HeatMapVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    private var weeksToShow: Int {
        switch timeFrame {
        case .week: return 1
        case .month: return 5
        case .threeMonths: return 13
        case .sixMonths: return 26
        case .year, .allTime: return 52
        }
    }

    private var heatMapData: [[Double]] {
        habit.heatMapData(weeks: weeksToShow)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 20)

                ForEach(0..<min(weeksToShow, 12), id: \.self) { week in
                    if week % 4 == 0 {
                        Text(monthLabel(for: week))
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Spacer()
            }

            HStack(spacing: 2) {
                // Weekday labels
                VStack(spacing: 2) {
                    ForEach(0..<7) { day in
                        Text(dayLabel(day))
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(width: 16, height: cellSize)
                    }
                }

                // Heat map grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(0..<weeksToShow, id: \.self) { week in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { day in
                                    let value = heatMapData[week][day]
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(colorForValue(value))
                                        .frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))

                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForValue(level))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private var cellSize: CGFloat {
        timeFrame == .week ? 28 : (timeFrame == .month ? 20 : 12)
    }

    private func dayLabel(_ day: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][day]
    }

    private func monthLabel(for week: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .weekOfYear, value: -(weeksToShow - 1 - week), to: today) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func colorForValue(_ value: Double) -> Color {
        if value < 0 {
            return .white.opacity(0.03)
        } else if value == 0 {
            return .white.opacity(0.08)
        } else if value < 0.25 {
            return habit.color.opacity(0.3)
        } else if value < 0.5 {
            return habit.color.opacity(0.5)
        } else if value < 0.75 {
            return habit.color.opacity(0.7)
        } else {
            return habit.color
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        HeatMapVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
            .padding()
    }
}
