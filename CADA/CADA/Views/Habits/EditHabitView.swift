import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var habit: Habit

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = ""
    @State private var selectedColor: HabitColorTheme = .blue
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var selectedVisualization: VisualizationType = .heatMap
    @State private var goalValue: Double = 1
    @State private var goalUnit: String = ""
    @State private var ratingScale: Int = 5
    @State private var notificationEnabled: Bool = true
    @State private var notificationTime: Date = Date()
    @State private var customDays: Set<Int> = []

    private let iconOptions = [
        "checkmark.circle", "star", "heart", "bolt", "flame",
        "drop", "leaf", "brain.head.profile", "figure.run", "dumbbell",
        "book", "pencil", "lightbulb", "moon", "sun.max",
        "cup.and.saucer", "fork.knife", "pills", "cross.case", "bed.double"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Info
                        VStack(spacing: 16) {
                            GlassTextField(title: "Habit name", text: $name, icon: "pencil")
                            GlassTextField(title: "Description", text: $description, icon: "text.alignleft")
                        }
                        .padding(20)
                        .glassCard()

                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? selectedColor.color.opacity(0.3) : .white.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                                .overlay {
                                                    Circle()
                                                        .stroke(selectedIcon == icon ? selectedColor.color : .clear, lineWidth: 2)
                                                }

                                            Image(systemName: icon)
                                                .font(.system(size: 18))
                                                .foregroundStyle(selectedIcon == icon ? selectedColor.color : .white.opacity(0.6))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(HabitColorTheme.allCases, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(colors: color.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .frame(width: 40, height: 40)

                                            if selectedColor == color {
                                                Circle()
                                                    .stroke(.white, lineWidth: 3)
                                                    .frame(width: 40, height: 40)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Frequency
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Frequency")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))

                            Picker("Frequency", selection: $selectedFrequency) {
                                ForEach(HabitFrequency.allCases, id: \.self) { freq in
                                    Text(freq.displayName).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)

                            if selectedFrequency == .custom {
                                HStack(spacing: 8) {
                                    ForEach(0..<7) { day in
                                        Button {
                                            if customDays.contains(day) {
                                                customDays.remove(day)
                                            } else {
                                                customDays.insert(day)
                                            }
                                        } label: {
                                            Text(["S", "M", "T", "W", "T", "F", "S"][day])
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(customDays.contains(day) ? .white : .white.opacity(0.5))
                                                .frame(width: 36, height: 36)
                                                .background {
                                                    Circle()
                                                        .fill(customDays.contains(day) ? selectedColor.color : .white.opacity(0.1))
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Goal (if applicable)
                        if habit.habitType != .boolean {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Goal")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.7))

                                HStack {
                                    Text("Target:")
                                        .foregroundStyle(.white.opacity(0.7))

                                    Spacer()

                                    HStack(spacing: 12) {
                                        Button {
                                            if goalValue > 1 { goalValue -= 1 }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(.white.opacity(0.6))
                                        }

                                        Text("\(Int(goalValue))")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 50)

                                        Button {
                                            goalValue += 1
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(selectedColor.color)
                                        }
                                    }
                                }

                                if habit.habitType != .rating && habit.habitType != .duration {
                                    GlassTextField(title: "Unit", text: $goalUnit, icon: "ruler")
                                }
                            }
                            .padding(20)
                            .glassCard()
                        }

                        // Visualization
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferred Visualization")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(VisualizationType.allCases, id: \.self) { viz in
                                        Button {
                                            selectedVisualization = viz
                                        } label: {
                                            VStack(spacing: 6) {
                                                Image(systemName: viz.icon)
                                                    .font(.system(size: 20))
                                                Text(viz.displayName)
                                                    .font(.caption2)
                                            }
                                            .foregroundStyle(selectedVisualization == viz ? .white : .white.opacity(0.5))
                                            .frame(width: 70, height: 60)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedVisualization == viz ? selectedColor.color.opacity(0.3) : .white.opacity(0.05))
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Notifications
                        VStack(spacing: 16) {
                            GlassToggle(title: "Daily reminder", isOn: $notificationEnabled, icon: "bell.fill")

                            if notificationEnabled {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.white.opacity(0.8))
                                    Text("Reminder time")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.white.opacity(0.08))
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundStyle(selectedColor.color)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            loadHabitData()
        }
    }

    private func loadHabitData() {
        name = habit.name
        description = habit.habitDescription
        selectedIcon = habit.icon
        selectedColor = habit.colorTheme
        selectedFrequency = habit.frequency
        selectedVisualization = habit.preferredVisualization
        goalValue = habit.goalValue
        goalUnit = habit.goalUnit
        ratingScale = habit.ratingScale
        notificationEnabled = habit.notificationEnabled
        notificationTime = habit.notificationTime
        customDays = Set(habit.customDays)
    }

    private func saveChanges() {
        habit.name = name
        habit.habitDescription = description
        habit.icon = selectedIcon
        habit.colorTheme = selectedColor
        habit.frequency = selectedFrequency
        habit.preferredVisualization = selectedVisualization
        habit.goalValue = goalValue
        habit.goalUnit = goalUnit
        habit.ratingScale = ratingScale
        habit.notificationEnabled = notificationEnabled
        habit.notificationTime = notificationTime
        habit.customDays = Array(customDays)

        if notificationEnabled {
            NotificationService.shared.scheduleHabitReminder(for: habit)
        } else {
            NotificationService.shared.cancelHabitReminder(for: habit)
        }

        dismiss()
    }
}

#Preview {
    EditHabitView(habit: Habit.sampleHabits[0])
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
