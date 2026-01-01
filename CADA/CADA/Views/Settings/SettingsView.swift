import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]

    @AppStorage("defaultNotificationTime") private var defaultNotificationTime: Double = 72000 // 20:00 in seconds
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("showStreakAnimations") private var showStreakAnimations = true
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday = false

    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingResetAlert = false
    @State private var showingSampleDataAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Notifications
                notificationsSection

                // Appearance
                appearanceSection

                // Data Management
                dataSection

                // About
                aboutSection

                // Debug (development only)
                #if DEBUG
                debugSection
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all habits and entries. This action cannot be undone.")
        }
        .alert("Add Sample Data", isPresented: $showingSampleDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                addSampleData()
            }
        } message: {
            Text("This will add sample habits with random entries for testing.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text("Customize your experience")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Notifications")

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Default Reminder Time",
                    subtitle: formattedTime(from: defaultNotificationTime)
                ) {
                    // Time picker would go here
                }

                Divider()
                    .background(.white.opacity(0.1))

                SettingsRow(
                    icon: "arrow.clockwise",
                    iconColor: .blue,
                    title: "Reschedule All",
                    subtitle: "Update all habit reminders"
                ) {
                    rescheduleAllNotifications()
                }
            }
            .glassCard(cornerRadius: 16)
        }
    }

    private func formattedTime(from seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Appearance")

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "hand.tap.fill",
                    iconColor: .purple,
                    title: "Haptic Feedback",
                    isOn: $hapticFeedback
                )

                Divider()
                    .background(.white.opacity(0.1))

                SettingsToggleRow(
                    icon: "sparkles",
                    iconColor: .orange,
                    title: "Streak Animations",
                    isOn: $showStreakAnimations
                )

                Divider()
                    .background(.white.opacity(0.1))

                SettingsToggleRow(
                    icon: "calendar",
                    iconColor: .green,
                    title: "Week Starts on Monday",
                    isOn: $weekStartsOnMonday
                )
            }
            .glassCard(cornerRadius: 16)
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Data")

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "square.and.arrow.up",
                    iconColor: .blue,
                    title: "Export Data",
                    subtitle: "Export habits as JSON"
                ) {
                    showingExportSheet = true
                }

                Divider()
                    .background(.white.opacity(0.1))

                SettingsRow(
                    icon: "square.and.arrow.down",
                    iconColor: .green,
                    title: "Import Data",
                    subtitle: "Import from backup"
                ) {
                    showingImportSheet = true
                }

                Divider()
                    .background(.white.opacity(0.1))

                SettingsRow(
                    icon: "trash",
                    iconColor: .red,
                    title: "Reset All Data",
                    subtitle: "Delete all habits and entries"
                ) {
                    showingResetAlert = true
                }
            }
            .glassCard(cornerRadius: 16)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "About")

            VStack(spacing: 0) {
                SettingsInfoRow(
                    icon: "info.circle.fill",
                    iconColor: .blue,
                    title: "Version",
                    value: "1.0.0"
                )

                Divider()
                    .background(.white.opacity(0.1))

                SettingsInfoRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Total Habits",
                    value: "\(habits.count)"
                )

                Divider()
                    .background(.white.opacity(0.1))

                SettingsInfoRow(
                    icon: "calendar.circle.fill",
                    iconColor: .purple,
                    title: "Total Entries",
                    value: "\(habits.flatMap { $0.entries }.count)"
                )

                Divider()
                    .background(.white.opacity(0.1))

                SettingsRow(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Rate CADA",
                    subtitle: "Love the app? Leave a review!"
                ) {
                    // Would open App Store rating
                }

                Divider()
                    .background(.white.opacity(0.1))

                SettingsRow(
                    icon: "envelope.fill",
                    iconColor: .teal,
                    title: "Send Feedback",
                    subtitle: "Help us improve"
                ) {
                    // Would open mail composer
                }
            }
            .glassCard(cornerRadius: 16)
        }
    }

    // MARK: - Debug Section

    #if DEBUG
    private var debugSection: some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "Debug")

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "plus.square.fill",
                    iconColor: .mint,
                    title: "Add Sample Data",
                    subtitle: "Create test habits with entries"
                ) {
                    showingSampleDataAlert = true
                }
            }
            .glassCard(cornerRadius: 16)
        }
    }
    #endif

    // MARK: - Actions

    private func rescheduleAllNotifications() {
        for habit in habits where habit.notificationEnabled {
            NotificationService.shared.scheduleHabitReminder(for: habit)
        }
    }

    private func resetAllData() {
        for habit in habits {
            modelContext.delete(habit)
        }
    }

    private func addSampleData() {
        for sampleHabit in Habit.sampleHabits {
            modelContext.insert(sampleHabit)

            // Generate sample entries
            let entries = HabitEntry.generateSampleEntries(for: sampleHabit, days: 90)
            for entry in entries {
                modelContext.insert(entry)
            }
        }
    }
}

// MARK: - Settings Row Components

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.blue)
                .labelsHidden()
        }
        .padding(14)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(14)
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
            .ignoresSafeArea()

        SettingsView()
    }
    .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
