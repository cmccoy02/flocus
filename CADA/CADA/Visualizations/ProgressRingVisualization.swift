import SwiftUI

struct ProgressRingVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var animatedProgress: Double = 0

    private var completionRate: Double {
        habit.completionRate(timeFrame: timeFrame)
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Background rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(.white.opacity(0.05), lineWidth: 8)
                        .frame(width: 160 - CGFloat(i) * 30, height: 160 - CGFloat(i) * 30)
                }

                // Main progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: habit.gradient + [habit.color.opacity(0.5)],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: habit.color.opacity(0.4), radius: 10)

                // Tick marks
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(.white.opacity(Double(i) / 12 <= completionRate ? 0.5 : 0.1))
                        .frame(width: 2, height: 8)
                        .offset(y: -90)
                        .rotationEffect(.degrees(Double(i) * 30))
                }

                // Center content
                VStack(spacing: 4) {
                    Text("\(Int(completionRate * 100))")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("%")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 180)

            // Stats
            HStack(spacing: 0) {
                ringStatItem(
                    value: "\(habit.entries(for: timeFrame).filter { $0.isCompleted }.count)",
                    label: "Completed",
                    color: habit.color
                )

                Divider()
                    .frame(height: 40)
                    .background(.white.opacity(0.2))

                ringStatItem(
                    value: "\(missedDays)",
                    label: "Missed",
                    color: .white.opacity(0.5)
                )

                Divider()
                    .frame(height: 40)
                    .background(.white.opacity(0.2))

                ringStatItem(
                    value: "\(habit.currentStreak)",
                    label: "Streak",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(duration: 1.2)) {
                animatedProgress = completionRate
            }
        }
    }

    private var missedDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var missed = 0

        for dayOffset in 0..<timeFrame.days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            if habit.shouldTrack(on: date) && !habit.isCompleted(for: date) {
                missed += 1
            }
        }

        return missed
    }

    private func ringStatItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        ProgressRingVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
    }
}
