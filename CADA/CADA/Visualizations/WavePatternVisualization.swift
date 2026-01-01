import SwiftUI

/// A visualization showing habit completion as rhythmic waves
/// Consistent habits create smooth, flowing patterns while inconsistency creates choppy waves
struct WavePatternVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var phase: CGFloat = 0

    private var completionData: [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = min(timeFrame.days, 30)

        return (0..<days).reversed().map { dayOffset -> Double in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return 0 }
            return habit.completionPercentage(for: date)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geo in
                ZStack {
                    // Background grid lines
                    ForEach(0..<5) { i in
                        Path { path in
                            let y = geo.size.height * CGFloat(i) / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                        .stroke(.white.opacity(0.05), lineWidth: 1)
                    }

                    // Wave paths
                    waveLayer(in: geo.size, opacity: 0.2, offset: phase * 0.5)
                    waveLayer(in: geo.size, opacity: 0.4, offset: phase * 0.7)
                    mainWave(in: geo.size)

                    // Data points
                    dataPointsView(in: geo.size)
                }
            }

            // Legend
            HStack(spacing: 20) {
                legendItem(color: habit.color, label: "Completed")
                legendItem(color: .white.opacity(0.3), label: "Missed")
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = 2 * .pi
            }
        }
    }

    private func waveLayer(in size: CGSize, opacity: Double, offset: CGFloat) -> some View {
        Path { path in
            let midY = size.height / 2
            let amplitude = size.height * 0.2

            path.move(to: CGPoint(x: 0, y: midY))

            for x in stride(from: 0, through: size.width, by: 2) {
                let relativeX = x / size.width
                let wave = sin((relativeX * 4 * .pi) + offset) * amplitude
                path.addLine(to: CGPoint(x: x, y: midY + wave))
            }
        }
        .stroke(
            LinearGradient(
                colors: [habit.color.opacity(opacity), habit.color.opacity(opacity * 0.5)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 2
        )
    }

    private func mainWave(in size: CGSize) -> some View {
        Path { path in
            guard !completionData.isEmpty else { return }

            let stepWidth = size.width / CGFloat(completionData.count - 1)
            let midY = size.height / 2

            path.move(to: CGPoint(x: 0, y: midY - (completionData[0] - 0.5) * size.height * 0.8))

            for (index, value) in completionData.enumerated() {
                let x = CGFloat(index) * stepWidth
                let y = midY - (value - 0.5) * size.height * 0.8

                if index == 0 {
                    continue
                }

                let prevX = CGFloat(index - 1) * stepWidth
                let prevValue = completionData[index - 1]
                let prevY = midY - (prevValue - 0.5) * size.height * 0.8

                let controlX1 = prevX + stepWidth * 0.5
                let controlX2 = x - stepWidth * 0.5

                path.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: controlX1, y: prevY),
                    control2: CGPoint(x: controlX2, y: y)
                )
            }
        }
        .stroke(
            LinearGradient(
                colors: habit.gradient,
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }

    private func dataPointsView(in size: CGSize) -> some View {
        let stepWidth = size.width / CGFloat(max(completionData.count - 1, 1))
        let midY = size.height / 2

        return ForEach(Array(completionData.enumerated()), id: \.offset) { index, value in
            let x = CGFloat(index) * stepWidth
            let y = midY - (value - 0.5) * size.height * 0.8

            Circle()
                .fill(value > 0 ? habit.color : .white.opacity(0.2))
                .frame(width: 8, height: 8)
                .overlay {
                    if value >= 1.0 {
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 2)
                    }
                }
                .position(x: x, y: y)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        WavePatternVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
            .frame(height: 200)
            .padding()
    }
}
