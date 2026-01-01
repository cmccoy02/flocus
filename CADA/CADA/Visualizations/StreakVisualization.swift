import SwiftUI

struct StreakVisualization: View {
    let habit: Habit
    @State private var animateFlame = false
    @State private var particleSystem = ParticleSystem()

    var body: some View {
        VStack(spacing: 24) {
            // Main streak display
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .orange.opacity(0.4),
                                .orange.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                    .scaleEffect(animateFlame ? 1.1 : 0.9)

                // Flame particles
                ForEach(particleSystem.particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .offset(particle.position)
                        .opacity(particle.opacity)
                }

                // Main flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 20)
                    .scaleEffect(animateFlame ? 1.05 : 1.0)
                    .offset(y: animateFlame ? -3 : 3)

                // Streak number overlay
                VStack {
                    Spacer()
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(y: 10)
                }
                .frame(height: 100)
            }
            .frame(height: 150)

            // Streak label
            VStack(spacing: 4) {
                Text(habit.currentStreak == 1 ? "day streak" : "day streak")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                if habit.currentStreak > 0 {
                    Text("Keep it going!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Streak comparison
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)

                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 40)

                VStack(spacing: 4) {
                    Text("\(habit.longestStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.yellow)

                    Text("Longest")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateFlame = true
            }
            startParticleAnimation()
        }
    }

    private func startParticleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            particleSystem.addParticle()
            particleSystem.update()
        }
    }
}

// MARK: - Particle System

struct Particle: Identifiable {
    let id = UUID()
    var position: CGSize
    var velocity: CGSize
    var size: CGFloat
    var opacity: Double
    var color: Color
    var lifetime: Double
}

class ParticleSystem: ObservableObject {
    @Published var particles: [Particle] = []

    func addParticle() {
        guard particles.count < 20 else { return }

        let particle = Particle(
            position: CGSize(width: CGFloat.random(in: -20...20), height: 40),
            velocity: CGSize(width: CGFloat.random(in: -1...1), height: CGFloat.random(in: -3...-1)),
            size: CGFloat.random(in: 4...10),
            opacity: Double.random(in: 0.5...1.0),
            color: [Color.yellow, Color.orange, Color.red].randomElement()!,
            lifetime: Double.random(in: 0.5...1.5)
        )
        particles.append(particle)
    }

    func update() {
        particles = particles.compactMap { particle in
            var updated = particle
            updated.position.width += particle.velocity.width
            updated.position.height += particle.velocity.height
            updated.opacity -= 0.05
            updated.size -= 0.2

            if updated.opacity <= 0 || updated.size <= 0 {
                return nil
            }
            return updated
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        StreakVisualization(habit: Habit.sampleHabits[0])
    }
}
