import SwiftUI

struct ShareHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let timeFrame: TimeFrame

    @State private var selectedStyle: ShareStyle = .card
    @State private var includeStreak = true
    @State private var includeStats = true
    @State private var includeVisualization = true
    @State private var renderedImage: UIImage?

    enum ShareStyle: String, CaseIterable {
        case card = "Card"
        case minimal = "Minimal"
        case detailed = "Detailed"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 12) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            sharePreview
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.black)
                                }
                        }

                        // Style selector
                        VStack(spacing: 12) {
                            Text("Style")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 10) {
                                ForEach(ShareStyle.allCases, id: \.self) { style in
                                    Button {
                                        selectedStyle = style
                                    } label: {
                                        Text(style.rawValue)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(selectedStyle == style ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background {
                                                Capsule()
                                                    .fill(selectedStyle == style ? habit.color.opacity(0.4) : .white.opacity(0.1))
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Options
                        VStack(spacing: 12) {
                            Text("Include")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 0) {
                                Toggle("Streak Count", isOn: $includeStreak)
                                    .tint(habit.color)
                                    .padding()

                                Divider()
                                    .background(.white.opacity(0.1))

                                Toggle("Statistics", isOn: $includeStats)
                                    .tint(habit.color)
                                    .padding()

                                Divider()
                                    .background(.white.opacity(0.1))

                                Toggle("Visualization", isOn: $includeVisualization)
                                    .tint(habit.color)
                                    .padding()
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(20)
                        .glassCard()

                        // Share button
                        ShareLink(
                            item: generateShareImage(),
                            preview: SharePreview(
                                "\(habit.name) Progress",
                                image: Image(uiImage: generateShareImage())
                            )
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: habit.gradient,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private var sharePreview: some View {
        switch selectedStyle {
        case .card:
            cardStylePreview
        case .minimal:
            minimalStylePreview
        case .detailed:
            detailedStylePreview
        }
    }

    private var cardStylePreview: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: habit.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(habit.habitType.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                if includeStreak && habit.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(habit.currentStreak)")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.orange.opacity(0.2)))
                }
            }

            if includeStats {
                HStack(spacing: 20) {
                    statItem(value: "\(Int(habit.completionRate(timeFrame: timeFrame) * 100))%", label: "Completion")
                    statItem(value: "\(habit.totalCompletions)", label: "Total")
                    statItem(value: "\(habit.longestStreak)", label: "Best Streak")
                }
            }

            if includeVisualization {
                MiniHeatMap(habit: habit)
                    .padding(.top, 8)
            }

            // Branding
            HStack {
                Text("Tracked with CADA")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))

                Spacer()
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.05, green: 0.05, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                }
        }
    }

    private var minimalStylePreview: some View {
        VStack(spacing: 12) {
            Image(systemName: habit.icon)
                .font(.system(size: 40))
                .foregroundStyle(habit.color)

            Text(habit.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            if includeStreak && habit.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(habit.currentStreak) day streak")
                }
                .font(.headline)
                .foregroundStyle(.white)
            }

            if includeStats {
                Text("\(Int(habit.completionRate(timeFrame: timeFrame) * 100))% completion rate")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text("CADA")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 8)
        }
        .padding(30)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
        }
    }

    private var detailedStylePreview: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text(timeFrame.displayName + " Progress")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: habit.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: habit.icon)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }
            }

            if includeVisualization {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 12)

                    Circle()
                        .trim(from: 0, to: habit.completionRate(timeFrame: timeFrame))
                        .stroke(
                            LinearGradient(colors: habit.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack {
                        Text("\(Int(habit.completionRate(timeFrame: timeFrame) * 100))%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Complete")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(height: 120)
            }

            if includeStats {
                HStack(spacing: 0) {
                    detailedStatItem(value: "\(habit.currentStreak)", label: "Current Streak", icon: "flame.fill", color: .orange)
                    detailedStatItem(value: "\(habit.longestStreak)", label: "Longest", icon: "crown.fill", color: .yellow)
                    detailedStatItem(value: "\(habit.totalCompletions)", label: "Total", icon: "checkmark.circle.fill", color: .green)
                }
            }

            if includeStreak && habit.currentStreak >= 7 {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)

                    Text("On a \(habit.currentStreak) day streak!")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.yellow.opacity(0.15))
                }
            }

            Text("CADA - Habit Tracker")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    private func detailedStatItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func generateShareImage() -> Image {
        let renderer = ImageRenderer(content: sharePreview.frame(width: 350))
        renderer.scale = 3.0

        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }

        return Image(systemName: "photo")
    }
}

#Preview {
    ShareHabitView(habit: Habit.sampleHabits[0], timeFrame: .month)
}
