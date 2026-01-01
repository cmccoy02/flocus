import SwiftUI

struct TrendGraphVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var animationProgress: CGFloat = 0
    @State private var selectedPoint: Int? = nil

    private var dataPoints: [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = min(timeFrame.days, 30)

        return (0..<days).compactMap { dayOffset -> (Date, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            return (date, habit.completionPercentage(for: date))
        }.reversed()
    }

    private var trendDirection: TrendDirection {
        guard dataPoints.count >= 7 else { return .neutral }

        let recentAvg = dataPoints.suffix(7).map { $0.value }.reduce(0, +) / 7
        let olderAvg = dataPoints.prefix(7).map { $0.value }.reduce(0, +) / 7

        if recentAvg > olderAvg + 0.1 { return .up }
        if recentAvg < olderAvg - 0.1 { return .down }
        return .neutral
    }

    var body: some View {
        VStack(spacing: 16) {
            // Trend indicator
            HStack {
                Image(systemName: trendDirection.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(trendDirection.color)

                Text(trendDirection.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                if let selected = selectedPoint, selected < dataPoints.count {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatDate(dataPoints[selected].date))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))

                        Text("\(Int(dataPoints[selected].value * 100))%")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(habit.color)
                    }
                }
            }

            // Graph
            GeometryReader { geo in
                ZStack {
                    // Grid lines
                    gridLines(in: geo.size)

                    // Area fill
                    areaPath(in: geo.size)
                        .fill(
                            LinearGradient(
                                colors: [habit.color.opacity(0.3), habit.color.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .mask {
                            Rectangle()
                                .frame(width: geo.size.width * animationProgress)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    // Line
                    linePath(in: geo.size)
                        .trim(from: 0, to: animationProgress)
                        .stroke(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: habit.color.opacity(0.5), radius: 5)

                    // Data points
                    dataPointsView(in: geo.size)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let index = Int((value.location.x / geo.size.width) * CGFloat(dataPoints.count))
                            selectedPoint = min(max(index, 0), dataPoints.count - 1)
                        }
                        .onEnded { _ in
                            selectedPoint = nil
                        }
                )
            }

            // X-axis labels
            HStack {
                ForEach([0, dataPoints.count / 2, dataPoints.count - 1], id: \.self) { index in
                    if index < dataPoints.count {
                        Text(formatShortDate(dataPoints[index].date))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    if index != dataPoints.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animationProgress = 1
            }
        }
    }

    private func gridLines(in size: CGSize) -> some View {
        ZStack {
            // Horizontal lines
            ForEach(0..<5) { i in
                Path { path in
                    let y = size.height * CGFloat(i) / 4
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(.white.opacity(0.05), lineWidth: 1)
            }

            // Y-axis labels
            VStack {
                Text("100%")
                Spacer()
                Text("50%")
                Spacer()
                Text("0%")
            }
            .font(.system(size: 8))
            .foregroundStyle(.white.opacity(0.3))
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: -25)
        }
    }

    private func linePath(in size: CGSize) -> Path {
        Path { path in
            guard !dataPoints.isEmpty else { return }

            let stepWidth = size.width / CGFloat(dataPoints.count - 1)

            for (index, data) in dataPoints.enumerated() {
                let x = CGFloat(index) * stepWidth
                let y = size.height * (1 - data.value)

                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    let prevX = CGFloat(index - 1) * stepWidth
                    let prevY = size.height * (1 - dataPoints[index - 1].value)

                    let controlX1 = prevX + stepWidth * 0.5
                    let controlX2 = x - stepWidth * 0.5

                    path.addCurve(
                        to: CGPoint(x: x, y: y),
                        control1: CGPoint(x: controlX1, y: prevY),
                        control2: CGPoint(x: controlX2, y: y)
                    )
                }
            }
        }
    }

    private func areaPath(in size: CGSize) -> Path {
        var path = linePath(in: size)

        if !dataPoints.isEmpty {
            let stepWidth = size.width / CGFloat(dataPoints.count - 1)
            path.addLine(to: CGPoint(x: CGFloat(dataPoints.count - 1) * stepWidth, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }

        return path
    }

    private func dataPointsView(in size: CGSize) -> some View {
        let stepWidth = size.width / CGFloat(max(dataPoints.count - 1, 1))

        return ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, data in
            let x = CGFloat(index) * stepWidth
            let y = size.height * (1 - data.value)

            Circle()
                .fill(data.value > 0 ? habit.color : .white.opacity(0.3))
                .frame(width: selectedPoint == index ? 12 : 6, height: selectedPoint == index ? 12 : 6)
                .overlay {
                    if selectedPoint == index {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    }
                }
                .position(x: x, y: y)
                .opacity(animationProgress > CGFloat(index) / CGFloat(dataPoints.count) ? 1 : 0)
                .animation(.easeOut.delay(Double(index) * 0.02), value: animationProgress)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

enum TrendDirection {
    case up, down, neutral

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .neutral: return .white.opacity(0.5)
        }
    }

    var label: String {
        switch self {
        case .up: return "Trending up"
        case .down: return "Trending down"
        case .neutral: return "Stable"
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        TrendGraphVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
            .frame(height: 220)
            .padding()
    }
}
