import SwiftUI

/// A unique visualization where completed habits form a constellation in the night sky
/// Stars light up and connect as you maintain your streak
struct ConstellationVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var stars: [Star] = []
    @State private var connections: [Connection] = []
    @State private var twinkle = false

    private var completedDays: Int {
        habit.entries(for: timeFrame).filter { $0.isCompleted }.count
    }

    private var totalDays: Int {
        timeFrame.days
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background stars (dim, static)
                ForEach(0..<50, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: CGFloat.random(in: 1...2))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                }

                // Connection lines
                ForEach(connections) { connection in
                    Path { path in
                        path.move(to: connection.start)
                        path.addLine(to: connection.end)
                    }
                    .stroke(
                        LinearGradient(
                            colors: [habit.color.opacity(0.3), habit.color.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
                }

                // Main constellation stars
                ForEach(stars) { star in
                    ZStack {
                        // Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [star.color.opacity(0.5), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: star.size * 2
                                )
                            )
                            .frame(width: star.size * 4, height: star.size * 4)

                        // Star
                        Circle()
                            .fill(star.isCompleted ? star.color : .white.opacity(0.2))
                            .frame(width: star.size, height: star.size)
                            .overlay {
                                if star.isCompleted {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: star.size * 0.4)
                                }
                            }
                    }
                    .position(star.position)
                    .opacity(star.isCompleted ? (twinkle && star.twinkles ? 0.7 : 1.0) : 0.3)
                    .scaleEffect(star.isCompleted && twinkle && star.twinkles ? 1.2 : 1.0)
                }

                // Constellation name
                VStack {
                    Spacer()

                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))

                        Text("\(completedDays) stars lit")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
            .onAppear {
                generateConstellation(in: geo.size)
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    twinkle = true
                }
            }
        }
    }

    private func generateConstellation(in size: CGSize) {
        let calendar = Calendar.current
        let entries = habit.entries(for: timeFrame)
        let padding: CGFloat = 30

        // Generate star positions in a constellation pattern
        var newStars: [Star] = []
        let daysToShow = min(timeFrame.days, 30)

        for i in 0..<daysToShow {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }

            let entry = entries.first { calendar.isDate($0.date, inSameDayAs: date) }
            let isCompleted = entry?.isCompleted ?? false

            // Create organic constellation positions
            let angle = (Double(i) / Double(daysToShow)) * 2 * .pi + Double.random(in: -0.3...0.3)
            let radius = CGFloat.random(in: 50...(min(size.width, size.height) / 2 - padding))

            let x = size.width / 2 + cos(angle) * radius * CGFloat.random(in: 0.7...1.3)
            let y = size.height / 2 + sin(angle) * radius * CGFloat.random(in: 0.7...1.3)

            newStars.append(Star(
                position: CGPoint(x: x, y: y),
                size: CGFloat.random(in: 6...12),
                color: isCompleted ? habit.color : .white.opacity(0.3),
                isCompleted: isCompleted,
                twinkles: Bool.random(),
                date: date
            ))
        }

        stars = newStars

        // Generate connections between nearby completed stars
        var newConnections: [Connection] = []
        let completedStars = stars.filter { $0.isCompleted }

        for (index, star) in completedStars.enumerated() {
            // Connect to 1-2 nearest completed stars
            let otherStars = completedStars.filter { $0.id != star.id }
            let nearest = otherStars.sorted { distance($0.position, star.position) < distance($1.position, star.position) }

            for nearStar in nearest.prefix(2) {
                if distance(star.position, nearStar.position) < 100 {
                    newConnections.append(Connection(start: star.position, end: nearStar.position))
                }
            }
        }

        connections = newConnections
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2))
    }
}

struct Star: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let color: Color
    let isCompleted: Bool
    let twinkles: Bool
    let date: Date
}

struct Connection: Identifiable {
    let id = UUID()
    let start: CGPoint
    let end: CGPoint
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        ConstellationVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
    }
}
