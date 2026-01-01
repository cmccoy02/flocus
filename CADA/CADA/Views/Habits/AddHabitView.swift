import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "checkmark.circle"
    @State private var selectedColor: HabitColorTheme = .blue
    @State private var selectedType: HabitType = .boolean
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var selectedVisualization: VisualizationType = .heatMap
    @State private var goalValue: Double = 1
    @State private var goalUnit = ""
    @State private var ratingScale = 5
    @State private var notificationEnabled = true
    @State private var notificationTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var customDays: Set<Int> = []

    @State private var currentStep = 0

    private let iconOptions = [
        "checkmark.circle", "star", "heart", "bolt", "flame",
        "drop", "leaf", "brain.head.profile", "figure.run", "dumbbell",
        "book", "pencil", "lightbulb", "moon", "sun.max",
        "cup.and.saucer", "fork.knife", "pills", "cross.case", "bed.double",
        "gamecontroller", "music.note", "paintbrush", "camera", "airplane"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator

                    // Content
                    TabView(selection: $currentStep) {
                        basicInfoStep.tag(0)
                        typeStep.tag(1)
                        customizationStep.tag(2)
                        notificationStep.tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? selectedColor.color : .white.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }

    // MARK: - Step 1: Basic Info

    private var basicInfoStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create New Habit")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                VStack(spacing: 16) {
                    GlassTextField(title: "Habit name", text: $name, icon: "pencil")

                    GlassTextField(title: "Description (optional)", text: $description, icon: "text.alignleft")
                }

                // Icon selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose an icon")
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
                                        .frame(width: 50, height: 50)
                                        .overlay {
                                            Circle()
                                                .stroke(
                                                    selectedIcon == icon ? selectedColor.color : .clear,
                                                    lineWidth: 2
                                                )
                                        }

                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedIcon == icon ? selectedColor.color : .white.opacity(0.6))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .glassCard()

                // Color selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a color")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(HabitColorTheme.allCases, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: color.gradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)

                                    if selectedColor == color {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .glassCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Step 2: Type

    private var typeStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("What type of habit?")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    ForEach(HabitType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(selectedType == type ? selectedColor.color.opacity(0.3) : .white.opacity(0.1))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: type.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedType == type ? selectedColor.color : .white.opacity(0.6))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(type.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .lineLimit(2)
                                }

                                Spacer()

                                if selectedType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(selectedColor.color)
                                }
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedType == type ? selectedColor.color : .clear, lineWidth: 2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Type-specific configuration
                typeConfiguration
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var typeConfiguration: some View {
        switch selectedType {
        case .boolean:
            EmptyView()

        case .count:
            VStack(spacing: 16) {
                Text("Set your daily goal")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack {
                    Text("Goal:")
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            if goalValue > 1 { goalValue -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        Text("\(Int(goalValue))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 60)

                        Button {
                            goalValue += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(selectedColor.color)
                        }
                    }
                }

                GlassTextField(title: "Unit (e.g., glasses, pages)", text: $goalUnit, icon: "textformat")
            }
            .padding(20)
            .glassCard()

        case .duration:
            VStack(spacing: 16) {
                Text("Set your daily goal")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack {
                    Text("Minutes:")
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            if goalValue > 5 { goalValue -= 5 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        Text("\(Int(goalValue))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 60)

                        Button {
                            goalValue += 5
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(selectedColor.color)
                        }
                    }
                }
            }
            .padding(20)
            .glassCard()

        case .measurement:
            VStack(spacing: 16) {
                Text("What are you tracking?")
                    .font(.headline)
                    .foregroundStyle(.white)

                GlassTextField(title: "Unit (e.g., lbs, steps)", text: $goalUnit, icon: "ruler")
            }
            .padding(20)
            .glassCard()

        case .rating:
            VStack(spacing: 16) {
                Text("Rating scale")
                    .font(.headline)
                    .foregroundStyle(.white)

                Picker("Scale", selection: $ratingScale) {
                    Text("1-5").tag(5)
                    Text("1-10").tag(10)
                }
                .pickerStyle(.segmented)
            }
            .padding(20)
            .glassCard()
        }
    }

    // MARK: - Step 3: Customization

    private var customizationStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Customize")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                // Frequency
                VStack(alignment: .leading, spacing: 12) {
                    Text("How often?")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))

                    VStack(spacing: 8) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            Button {
                                selectedFrequency = frequency
                            } label: {
                                HStack {
                                    Image(systemName: frequency.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(selectedFrequency == frequency ? selectedColor.color : .white.opacity(0.5))
                                        .frame(width: 28)

                                    Text(frequency.displayName)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)

                                    Spacer()

                                    if selectedFrequency == frequency {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(selectedColor.color)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedFrequency == frequency ? selectedColor.color.opacity(0.15) : .white.opacity(0.05))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .glassCard()

                // Custom days (if custom frequency selected)
                if selectedFrequency == .custom {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select days")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))

                        HStack(spacing: 8) {
                            ForEach(0..<7) { day in
                                Button {
                                    if customDays.contains(day) {
                                        customDays.remove(day)
                                    } else {
                                        customDays.insert(day)
                                    }
                                } label: {
                                    Text(dayAbbreviation(day))
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(customDays.contains(day) ? .white : .white.opacity(0.5))
                                        .frame(width: 40, height: 40)
                                        .background {
                                            Circle()
                                                .fill(customDays.contains(day) ? selectedColor.color : .white.opacity(0.1))
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                    .glassCard()
                }

                // Preferred visualization
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred visualization")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(VisualizationType.allCases, id: \.self) { viz in
                                Button {
                                    selectedVisualization = viz
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: viz.icon)
                                            .font(.system(size: 24))

                                        Text(viz.displayName)
                                            .font(.caption2)
                                    }
                                    .foregroundStyle(selectedVisualization == viz ? .white : .white.opacity(0.5))
                                    .frame(width: 80, height: 70)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedVisualization == viz ? selectedColor.color.opacity(0.3) : .white.opacity(0.05))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedVisualization == viz ? selectedColor.color : .clear,
                                                        lineWidth: 1
                                                    )
                                            }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
                .glassCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func dayAbbreviation(_ day: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[day]
    }

    // MARK: - Step 4: Notifications

    private var notificationStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Reminders")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                // Preview card
                previewCard

                // Notification toggle
                VStack(spacing: 16) {
                    GlassToggle(title: "Daily reminder", isOn: $notificationEnabled, icon: "bell.fill")

                    if notificationEnabled {
                        HStack {
                            Image(systemName: "clock")
                                .font(.system(size: 20))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 28)

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
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                }
                        }
                    }
                }
                .padding(20)
                .glassCard()

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private var previewCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: selectedColor.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: selectedIcon)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }
                .glow(color: selectedColor.color, radius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(name.isEmpty ? "Your Habit" : name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(selectedType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()
            }

            Divider()
                .background(.white.opacity(0.2))

            HStack {
                Label(selectedFrequency.displayName, systemImage: "calendar")
                Spacer()
                Label(selectedVisualization.displayName, systemImage: selectedVisualization.icon)
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(20)
        .glassCard()
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                }
                .buttonStyle(FrostedButtonStyle())
            }

            Spacer()

            Button {
                if currentStep < 3 {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep += 1
                    }
                } else {
                    createHabit()
                }
            } label: {
                HStack {
                    Text(currentStep < 3 ? "Next" : "Create Habit")
                    if currentStep < 3 {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
            }
            .buttonStyle(FrostedButtonStyle(color: selectedColor.color))
            .disabled(name.isEmpty && currentStep == 0)
            .opacity(name.isEmpty && currentStep == 0 ? 0.5 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial.opacity(0.5))
    }

    private func createHabit() {
        let habit = Habit(
            name: name,
            description: description,
            icon: selectedIcon,
            colorTheme: selectedColor,
            habitType: selectedType,
            frequency: selectedFrequency,
            preferredVisualization: selectedVisualization,
            goalValue: goalValue,
            goalUnit: goalUnit,
            ratingScale: ratingScale,
            notificationEnabled: notificationEnabled,
            notificationTime: notificationTime,
            customDays: Array(customDays)
        )

        modelContext.insert(habit)

        if notificationEnabled {
            NotificationService.shared.scheduleHabitReminder(for: habit)
        }

        dismiss()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
