import SwiftUI
import SwiftData

struct DailyEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var allHabits: [Habit]

    @State private var entryDate = Date()
    @State private var habitEntries: [UUID: HabitEntryState] = [:]
    @State private var currentIndex = 0
    @State private var showingDatePicker = false

    private var todaysHabits: [Habit] {
        allHabits.filter { $0.shouldTrack(on: entryDate) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Date selector
                    dateSelector

                    // Progress indicator
                    progressIndicator

                    if todaysHabits.isEmpty {
                        emptyStateView
                    } else {
                        // Habit entry cards
                        TabView(selection: $currentIndex) {
                            ForEach(Array(todaysHabits.enumerated()), id: \.element.id) { index, habit in
                                HabitEntryCard(
                                    habit: habit,
                                    entryState: binding(for: habit)
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))

                        // Navigation buttons
                        navigationButtons
                    }
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

                ToolbarItem(placement: .principal) {
                    Text("Daily Log")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveAllEntries()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            loadExistingEntries()
        }
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        HStack {
            Button {
                withAnimation {
                    entryDate = Calendar.current.date(byAdding: .day, value: -1, to: entryDate) ?? entryDate
                    loadExistingEntries()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Button {
                showingDatePicker.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))

                    Text(formattedDate)
                        .font(.headline)

                    if Calendar.current.isDateInToday(entryDate) {
                        Text("Today")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(.blue.opacity(0.3))
                            }
                    }
                }
                .foregroundStyle(.white)
            }

            Spacer()

            Button {
                withAnimation {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: entryDate) ?? entryDate
                    if tomorrow <= Date() {
                        entryDate = tomorrow
                        loadExistingEntries()
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(canGoForward ? .white.opacity(0.6) : .white.opacity(0.2))
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $entryDate) {
                loadExistingEntries()
            }
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: entryDate)
    }

    private var canGoForward: Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: entryDate) ?? entryDate
        return tomorrow <= Date()
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(Array(todaysHabits.enumerated()), id: \.element.id) { index, habit in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            index <= currentIndex
                                ? LinearGradient(colors: habit.gradient, startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(height: 4)
                }
            }

            Text("\(currentIndex + 1) of \(todaysHabits.count)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green.opacity(0.5))

            Text("No habits to track")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text("You don't have any habits scheduled for this day")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(40)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentIndex > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentIndex -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                }
                .buttonStyle(FrostedButtonStyle())
            }

            Spacer()

            if currentIndex < todaysHabits.count - 1 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentIndex += 1
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                }
                .buttonStyle(FrostedButtonStyle(color: todaysHabits[currentIndex].color))
            } else {
                Button {
                    saveAllEntries()
                    dismiss()
                } label: {
                    HStack {
                        Text("Complete")
                        Image(systemName: "checkmark")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                }
                .buttonStyle(FrostedButtonStyle(color: .green))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial.opacity(0.3))
    }

    // MARK: - Helper Functions

    private func binding(for habit: Habit) -> Binding<HabitEntryState> {
        Binding(
            get: { habitEntries[habit.id] ?? HabitEntryState(habit: habit) },
            set: { habitEntries[habit.id] = $0 }
        )
    }

    private func loadExistingEntries() {
        habitEntries = [:]
        let calendar = Calendar.current

        for habit in todaysHabits {
            if let existingEntry = habit.entries.first(where: { calendar.isDate($0.date, inSameDayAs: entryDate) }) {
                habitEntries[habit.id] = HabitEntryState(
                    habit: habit,
                    isCompleted: existingEntry.booleanValue,
                    value: existingEntry.value,
                    notes: existingEntry.notes
                )
            } else {
                habitEntries[habit.id] = HabitEntryState(habit: habit)
            }
        }
    }

    private func saveAllEntries() {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: entryDate)

        for habit in todaysHabits {
            guard let state = habitEntries[habit.id] else { continue }

            // Find existing entry or create new
            if let existingEntry = habit.entries.first(where: { calendar.isDate($0.date, inSameDayAs: targetDate) }) {
                existingEntry.booleanValue = state.isCompleted
                existingEntry.value = state.value
                existingEntry.notes = state.notes
            } else if state.isCompleted || state.value > 0 {
                let entry = HabitEntry(
                    date: targetDate,
                    booleanValue: state.isCompleted,
                    value: state.value,
                    notes: state.notes,
                    habit: habit
                )
                modelContext.insert(entry)
            }
        }
    }
}

// MARK: - Habit Entry State

struct HabitEntryState {
    var isCompleted: Bool = false
    var value: Double = 0
    var notes: String = ""

    init(habit: Habit) {
        self.isCompleted = false
        self.value = 0
        self.notes = ""
    }

    init(habit: Habit, isCompleted: Bool, value: Double, notes: String) {
        self.isCompleted = isCompleted
        self.value = value
        self.notes = notes
    }
}

// MARK: - Habit Entry Card

struct HabitEntryCard: View {
    let habit: Habit
    @Binding var entryState: HabitEntryState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Habit icon and name
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: habit.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: habit.color.opacity(0.5), radius: 20, y: 10)

                    Image(systemName: habit.icon)
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 4) {
                    Text(habit.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    if !habit.habitDescription.isEmpty {
                        Text(habit.habitDescription)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }

            // Input based on habit type
            habitInput
                .padding(24)
                .glassCard()

            // Notes field
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                TextField("Add a note...", text: $entryState.notes, axis: .vertical)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.08))
                    }
                    .lineLimit(3)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var habitInput: some View {
        switch habit.habitType {
        case .boolean:
            booleanInput

        case .count:
            countInput

        case .duration:
            durationInput

        case .measurement:
            measurementInput

        case .rating:
            ratingInput
        }
    }

    // MARK: - Boolean Input

    private var booleanInput: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                entryState.isCompleted.toggle()
            }
        } label: {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(entryState.isCompleted ? habit.color : .white.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: entryState.isCompleted ? "checkmark" : "xmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(entryState.isCompleted ? .white : .white.opacity(0.3))
                }

                Text(entryState.isCompleted ? "Completed!" : "Tap to mark complete")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Count Input

    private var countInput: some View {
        VStack(spacing: 16) {
            Text("How many?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 24) {
                Button {
                    if entryState.value > 0 {
                        entryState.value -= 1
                        updateCompletion()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.5))
                }

                VStack(spacing: 4) {
                    Text("\(Int(entryState.value))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !habit.goalUnit.isEmpty {
                        Text(habit.goalUnit)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(minWidth: 100)

                Button {
                    entryState.value += 1
                    updateCompletion()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(habit.color)
                }
            }

            // Goal indicator
            if habit.goalValue > 0 {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: habit.gradient,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * min(entryState.value / habit.goalValue, 1))
                        }
                    }
                    .frame(height: 8)

                    Text("Goal: \(Int(habit.goalValue)) \(habit.goalUnit)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    // MARK: - Duration Input

    private var durationInput: some View {
        VStack(spacing: 16) {
            Text("How long?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 24) {
                Button {
                    if entryState.value >= 5 {
                        entryState.value -= 5
                        updateCompletion()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.5))
                }

                VStack(spacing: 4) {
                    Text(formatDuration(entryState.value))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("minutes")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(minWidth: 120)

                Button {
                    entryState.value += 5
                    updateCompletion()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(habit.color)
                }
            }

            // Quick buttons
            HStack(spacing: 10) {
                ForEach([5, 10, 15, 30, 60], id: \.self) { minutes in
                    Button {
                        entryState.value = Double(minutes)
                        updateCompletion()
                    } label: {
                        Text("\(minutes)m")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(entryState.value == Double(minutes) ? habit.color.opacity(0.5) : .white.opacity(0.1))
                            }
                    }
                }
            }
        }
    }

    private func formatDuration(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60

        if hours > 0 {
            return "\(hours):\(String(format: "%02d", mins))"
        }
        return "\(mins)"
    }

    // MARK: - Measurement Input

    private var measurementInput: some View {
        VStack(spacing: 16) {
            Text("Enter value")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            HStack {
                TextField("0", value: $entryState.value, format: .number)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .onChange(of: entryState.value) { _, _ in
                        updateCompletion()
                    }

                if !habit.goalUnit.isEmpty {
                    Text(habit.goalUnit)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Rating Input

    private var ratingInput: some View {
        VStack(spacing: 16) {
            Text("Rate your \(habit.name.lowercased())")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 8) {
                ForEach(1...habit.ratingScale, id: \.self) { rating in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            entryState.value = Double(rating)
                            entryState.isCompleted = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    Double(rating) <= entryState.value
                                        ? LinearGradient(colors: habit.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: habit.ratingScale <= 5 ? 56 : 32, height: habit.ratingScale <= 5 ? 56 : 32)

                            Text("\(rating)")
                                .font(habit.ratingScale <= 5 ? .title2.weight(.bold) : .caption.weight(.bold))
                                .foregroundStyle(Double(rating) <= entryState.value ? .white : .white.opacity(0.4))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if entryState.value > 0 {
                Text("\(Int(entryState.value)) out of \(habit.ratingScale)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private func updateCompletion() {
        entryState.isCompleted = entryState.value >= habit.goalValue
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let onDateChange: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDateChange()
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    DailyEntryView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
