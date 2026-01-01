import SwiftUI

// MARK: - Liquid Glass Background

struct LiquidGlassBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.06, blue: 0.18),
                    Color(red: 0.03, green: 0.03, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated orbs
            GeometryReader { geo in
                ZStack {
                    // Purple orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.purple.opacity(0.5),
                                    Color.purple.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.4
                            )
                        )
                        .frame(width: geo.size.width * 0.8)
                        .offset(
                            x: animate ? -geo.size.width * 0.1 : -geo.size.width * 0.3,
                            y: animate ? -geo.size.height * 0.2 : -geo.size.height * 0.1
                        )
                        .blur(radius: 60)

                    // Blue orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.4),
                                    Color.cyan.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.35
                            )
                        )
                        .frame(width: geo.size.width * 0.7)
                        .offset(
                            x: animate ? geo.size.width * 0.3 : geo.size.width * 0.1,
                            y: animate ? geo.size.height * 0.3 : geo.size.height * 0.4
                        )
                        .blur(radius: 50)

                    // Teal accent
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.teal.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.25
                            )
                        )
                        .frame(width: geo.size.width * 0.5)
                        .offset(
                            x: animate ? geo.size.width * 0.2 : geo.size.width * 0.4,
                            y: animate ? -geo.size.height * 0.1 : 0
                        )
                        .blur(radius: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var opacity: CGFloat = 0.15
    var borderOpacity: CGFloat = 0.25

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(opacity))
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.1),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(borderOpacity),
                                        .white.opacity(0.1),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, opacity: CGFloat = 0.15) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Frosted Glass Button Style

struct FrostedButtonStyle: ButtonStyle {
    var color: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .fill(color.opacity(configuration.isPressed ? 0.3 : 0.15))
                    .overlay {
                        Capsule()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .white.opacity(0.2),
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Glow Effect

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
            .shadow(color: color.opacity(0.1), radius: radius * 1.5)
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Liquid Glass Input Field

struct GlassTextField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 24)
            }

            TextField(title, text: $text)
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

// MARK: - Liquid Glass Toggle

struct GlassToggle: View {
    let title: String
    @Binding var isOn: Bool
    var icon: String? = nil

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 28)
            }

            Text(title)
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.blue)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

// MARK: - Section Header

struct GlassSectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            if let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    var color: Color = .blue
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: color.opacity(0.5), radius: 12, y: 6)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Liquid Glass Theme")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                GlassTextField(title: "Enter habit name", text: .constant(""), icon: "pencil")

                GlassToggle(title: "Notifications", isOn: .constant(true), icon: "bell")
            }
            .padding()
            .glassCard()

            Button("Frosted Button") {}
                .buttonStyle(FrostedButtonStyle(color: .blue))
        }
        .padding()
    }
}
