import SwiftUI

/// A unique visualization where habits grow as flowers in a garden
/// More consistent habits bloom fuller, while missed days cause wilting
struct BloomGardenVisualization: View {
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var bloomScale: CGFloat = 0
    @State private var sway = false

    private var completionRate: Double {
        habit.completionRate(timeFrame: timeFrame)
    }

    private var flowerStage: FlowerStage {
        switch completionRate {
        case 0..<0.2: return .seed
        case 0.2..<0.4: return .sprout
        case 0.4..<0.6: return .bud
        case 0.6..<0.8: return .blooming
        default: return .fullBloom
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Main flower display
            ZStack {
                // Ground/pot
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.brown.opacity(0.6), Color.brown.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 30)
                    .offset(y: 80)

                // Flower based on stage
                flowerView
                    .scaleEffect(bloomScale)
            }
            .frame(height: 180)

            // Stage label
            VStack(spacing: 4) {
                Text(flowerStage.displayName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Text(flowerStage.message)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            // Growth progress
            VStack(spacing: 8) {
                HStack {
                    ForEach(FlowerStage.allCases, id: \.self) { stage in
                        VStack(spacing: 4) {
                            Image(systemName: stage.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(stage.rawValue <= flowerStage.rawValue ? habit.color : .white.opacity(0.3))

                            if stage.rawValue < FlowerStage.allCases.count - 1 {
                                Rectangle()
                                    .fill(stage.rawValue < flowerStage.rawValue ? habit.color : .white.opacity(0.2))
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                Text("\(Int(completionRate * 100))% growth")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(duration: 1, bounce: 0.3)) {
                bloomScale = 1
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sway = true
            }
        }
    }

    @ViewBuilder
    private var flowerView: some View {
        switch flowerStage {
        case .seed:
            seedView
        case .sprout:
            sproutView
        case .bud:
            budView
        case .blooming:
            bloomingView
        case .fullBloom:
            fullBloomView
        }
    }

    private var seedView: some View {
        VStack {
            Spacer()
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.brown, Color(red: 0.4, green: 0.3, blue: 0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 12)
                .offset(y: 70)
        }
    }

    private var sproutView: some View {
        VStack {
            Spacer()

            // Small leaves
            ZStack {
                // Stem
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 60), control: CGPoint(x: sway ? 5 : -5, y: 30))
                }
                .stroke(Color.green.opacity(0.8), lineWidth: 3)
                .frame(width: 10, height: 60)

                // Leaf
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [.green, Color(red: 0.2, green: 0.6, blue: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 12)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 12, y: -20)
            }
            .offset(y: 50)
        }
    }

    private var budView: some View {
        VStack {
            Spacer()

            ZStack {
                // Stem
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 80), control: CGPoint(x: sway ? 8 : -8, y: 40))
                }
                .stroke(Color.green.opacity(0.8), lineWidth: 4)
                .frame(width: 20, height: 80)

                // Leaves
                ForEach([-1, 1], id: \.self) { direction in
                    Ellipse()
                        .fill(LinearGradient(colors: [.green, .green.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 25, height: 15)
                        .rotationEffect(.degrees(Double(direction) * 40))
                        .offset(x: CGFloat(direction) * 18, y: 20)
                }

                // Bud
                Ellipse()
                    .fill(habit.color.opacity(0.8))
                    .frame(width: 25, height: 30)
                    .offset(y: -70)
            }
            .offset(y: 40)
        }
    }

    private var bloomingView: some View {
        VStack {
            Spacer()

            ZStack {
                // Stem
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 100), control: CGPoint(x: sway ? 10 : -10, y: 50))
                }
                .stroke(Color.green.opacity(0.8), lineWidth: 5)
                .frame(width: 20, height: 100)

                // Leaves
                ForEach([-1, 1], id: \.self) { direction in
                    Ellipse()
                        .fill(LinearGradient(colors: [.green, .green.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 30, height: 18)
                        .rotationEffect(.degrees(Double(direction) * 45))
                        .offset(x: CGFloat(direction) * 22, y: 20)
                }

                // Partial petals
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: habit.gradient,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 20, height: 35)
                            .offset(y: -15)
                            .rotationEffect(.degrees(Double(i) * 72))
                    }

                    Circle()
                        .fill(.yellow)
                        .frame(width: 20, height: 20)
                }
                .offset(y: -90)
            }
            .offset(y: 40)
        }
    }

    private var fullBloomView: some View {
        VStack {
            Spacer()

            ZStack {
                // Stem
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 110), control: CGPoint(x: sway ? 12 : -12, y: 55))
                }
                .stroke(Color.green, lineWidth: 6)
                .frame(width: 24, height: 110)

                // Leaves
                ForEach([-1, 1], id: \.self) { direction in
                    Ellipse()
                        .fill(LinearGradient(colors: [.green, .green.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 35, height: 20)
                        .rotationEffect(.degrees(Double(direction) * 50))
                        .offset(x: CGFloat(direction) * 25, y: 30)
                }

                // Full bloom flower
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [habit.color.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    // Petals
                    ForEach(0..<8, id: \.self) { i in
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: habit.gradient + [.white.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 28, height: 45)
                            .offset(y: -20)
                            .rotationEffect(.degrees(Double(i) * 45))
                    }

                    // Center
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow, .orange.opacity(0.8)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                }
                .offset(y: -100)
                .shadow(color: habit.color.opacity(0.5), radius: 15)
            }
            .offset(y: 40)
        }
    }
}

enum FlowerStage: Int, CaseIterable {
    case seed = 0
    case sprout = 1
    case bud = 2
    case blooming = 3
    case fullBloom = 4

    var displayName: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .bud: return "Bud"
        case .blooming: return "Blooming"
        case .fullBloom: return "Full Bloom"
        }
    }

    var message: String {
        switch self {
        case .seed: return "Keep going! Your habit is just starting"
        case .sprout: return "Growing stronger every day"
        case .bud: return "Almost there! Keep up the momentum"
        case .blooming: return "Beautiful progress! Stay consistent"
        case .fullBloom: return "Amazing! Your habit is thriving!"
        }
    }

    var icon: String {
        switch self {
        case .seed: return "circle.fill"
        case .sprout: return "leaf.fill"
        case .bud: return "camera.macro"
        case .blooming: return "sparkle"
        case .fullBloom: return "sparkles"
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        BloomGardenVisualization(habit: Habit.sampleHabits[0], timeFrame: .month)
    }
}
