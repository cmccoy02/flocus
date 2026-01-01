import SwiftUI

/// A radial visualization showing habit completion as rays emanating from center
/// Each day is represented as a ray, with completed days glowing brightly
struct RadialBurstVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var animationProgress: CGFloat = 0
    @State private var pulseScale: CGFloat = 1

    private var daysToShow: Int {
        min(timeFrame.days, 30)
    }

    private var completionData: [(date: Date, completion: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<daysToShow).compactMap { dayOffset -> (Date, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            return (date, habit.completionPercentage(for: date))
        }.reversed()
    }

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let maxRadius = min(geo.size.width, geo.size.height) / 2 - 20

                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [habit.color.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: maxRadius
                            )
                        )
                        .scaleEffect(pulseScale)

                    // Background circles
                    ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                        Circle()
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                            .frame(width: maxRadius * 2 * level, height: maxRadius * 2 * level)
                    }

                    // Rays
                    ForEach(Array(completionData.enumerated()), id: \.offset) { index, data in
                        let angle = (Double(index) / Double(daysToShow)) * 2 * .pi - .pi / 2
                        let rayLength = maxRadius * data.completion * animationProgress

                        Path { path in
                            path.move(to: center)
                            let endPoint = CGPoint(
                                x: center.x + cos(angle) * rayLength,
                                y: center.y + sin(angle) * rayLength
                            )
                            path.addLine(to: endPoint)
                        }
                        .stroke(
                            LinearGradient(
                                colors: data.completion > 0 ? habit.gradient : [.white.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .shadow(color: data.completion > 0.5 ? habit.color.opacity(0.5) : .clear, radius: 5)

                        // Ray tips
                        if data.completion > 0 {
                            Circle()
                                .fill(habit.color)
                                .frame(width: 6, height: 6)
                                .position(
                                    x: center.x + cos(angle) * rayLength,
                                    y: center.y + sin(angle) * rayLength
                                )
                                .opacity(animationProgress)
                        }
                    }

                    // Center orb
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: habit.gradient + [habit.color.opacity(0.5)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: habit.color.opacity(0.5), radius: 10)

                        Text("\(Int(averageCompletion * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .position(center)

                    // Day labels (every 7 days)
                    ForEach(Array(stride(from: 0, to: daysToShow, by: 7)), id: \.self) { index in
                        let angle = (Double(index) / Double(daysToShow)) * 2 * .pi - .pi / 2
                        let labelRadius = maxRadius + 15

                        Text("D\(index + 1)")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.4))
                            .position(
                                x: center.x + cos(angle) * labelRadius,
                                y: center.y + sin(angle) * labelRadius
                            )
                    }
                }
            }

            // Stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(completedDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(habit.color)

                    Text("Completed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                VStack(spacing: 4) {
                    Text("\(daysToShow - completedDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))

                    Text("Missed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1)) {
                animationProgress = 1
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }

    private var averageCompletion: Double {
        guard !completionData.isEmpty else { return 0 }
        return completionData.map { $0.completion }.reduce(0, +) / Double(completionData.count)
    }

    private var completedDays: Int {
        completionData.filter { $0.completion > 0 }.count
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        RadialBurstVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
            .frame(height: 280)
            .padding()
    }
}
