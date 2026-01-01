import SwiftUI

struct CalendarGridVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var selectedDate: Date? = nil

    private var calendar: Calendar { Calendar.current }

    private var monthsToShow: Int {
        switch timeFrame {
        case .week: return 1
        case .month: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .year, .allTime: return 12
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<monthsToShow, id: \.self) { monthOffset in
                    if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
                        monthView(for: monthDate)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func monthView(for date: Date) -> some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Text(monthYearString(from: date))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(completionPercentage(for: date))%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(habit.color)
            }

            // Day headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            let days = daysInMonth(for: date)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        dayCell(for: day)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }

    private func dayCell(for date: Date) -> some View {
        let isCompleted = habit.isCompleted(for: date)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        let shouldTrack = habit.shouldTrack(on: date)
        let completion = habit.completionPercentage(for: date)

        return Button {
            selectedDate = date
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(backgroundColor(isCompleted: isCompleted, shouldTrack: shouldTrack, isFuture: isFuture, completion: completion))

                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption.weight(isToday ? .bold : .regular))
                    .foregroundStyle(foregroundColor(isCompleted: isCompleted, shouldTrack: shouldTrack, isFuture: isFuture))

                // Today indicator
                if isToday {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(habit.color, lineWidth: 2)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    private func backgroundColor(isCompleted: Bool, shouldTrack: Bool, isFuture: Bool, completion: Double) -> Color {
        if isFuture {
            return .white.opacity(0.02)
        }
        if !shouldTrack {
            return .white.opacity(0.03)
        }
        if isCompleted || completion > 0 {
            return habit.color.opacity(0.2 + completion * 0.6)
        }
        return .white.opacity(0.05)
    }

    private func foregroundColor(isCompleted: Bool, shouldTrack: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return .white.opacity(0.2)
        }
        if !shouldTrack {
            return .white.opacity(0.3)
        }
        if isCompleted {
            return .white
        }
        return .white.opacity(0.6)
    }

    private func daysInMonth(for date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(dayDate)
            }
        }

        // Pad to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func completionPercentage(for monthDate: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: monthDate)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!

        var trackableDays = 0
        var completedDays = 0

        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay),
               dayDate <= Date() {
                if habit.shouldTrack(on: dayDate) {
                    trackableDays += 1
                    if habit.isCompleted(for: dayDate) {
                        completedDays += 1
                    }
                }
            }
        }

        return trackableDays > 0 ? Int(Double(completedDays) / Double(trackableDays) * 100) : 0
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        CalendarGridVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
            .padding()
    }
}
