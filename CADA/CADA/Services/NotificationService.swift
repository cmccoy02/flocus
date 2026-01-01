import Foundation
import UserNotifications
import SwiftUI

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private override init() {
        super.init()
        checkAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error)")
                }
            }
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Habit Reminders

    func scheduleHabitReminder(for habit: Habit) {
        guard habit.notificationEnabled else { return }

        // Remove existing notifications for this habit
        cancelHabitReminder(for: habit)

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to track: \(habit.name)"
        content.body = getMotivationalMessage(for: habit)
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitId": habit.id.uuidString]

        // Set up the trigger based on habit frequency
        let triggers = createTriggers(for: habit)

        for (index, trigger) in triggers.enumerated() {
            let identifier = "\(habit.id.uuidString)-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func cancelHabitReminder(for habit: Habit) {
        // Remove all notifications for this habit
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.starts(with: habit.id.uuidString) }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Daily Entry Reminder

    func scheduleDailyEntryReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Log your habits"
        content.body = "Take a moment to record today's progress"
        content.sound = .default
        content.categoryIdentifier = "DAILY_ENTRY"

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "daily-entry-reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }

    // MARK: - Streak Celebration

    func scheduleStreakCelebration(for habit: Habit, streakCount: Int) {
        guard streakCount > 0 && (streakCount == 7 || streakCount == 30 || streakCount == 100 || streakCount % 50 == 0) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Milestone Achieved!"
        content.body = "\(streakCount) day streak for \(habit.name)! Amazing consistency!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_CELEBRATION"

        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak-\(habit.id.uuidString)-\(streakCount)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Helper Methods

    private func createTriggers(for habit: Habit) -> [UNCalendarNotificationTrigger] {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: habit.notificationTime)

        switch habit.frequency {
        case .daily:
            var components = DateComponents()
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: true)]

        case .weekdays:
            return (2...6).map { weekday in
                var components = DateComponents()
                components.weekday = weekday
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            }

        case .weekends:
            return [1, 7].map { weekday in
                var components = DateComponents()
                components.weekday = weekday
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            }

        case .weekly:
            let creationWeekday = calendar.component(.weekday, from: habit.createdAt)
            var components = DateComponents()
            components.weekday = creationWeekday
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: true)]

        case .custom:
            return habit.customDays.map { day in
                var components = DateComponents()
                components.weekday = day + 1 // Convert 0-indexed to 1-indexed
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            }
        }
    }

    private func getMotivationalMessage(for habit: Habit) -> String {
        let messages: [String]

        if habit.currentStreak > 0 {
            messages = [
                "Keep your \(habit.currentStreak) day streak going!",
                "You're on fire with \(habit.currentStreak) days!",
                "Don't break the chain - day \(habit.currentStreak + 1) awaits!",
                "\(habit.currentStreak) days strong. Make it \(habit.currentStreak + 1)!"
            ]
        } else {
            messages = [
                "Start fresh today!",
                "Today is a new opportunity",
                "Small steps lead to big changes",
                "You've got this!"
            ]
        }

        return messages.randomElement() ?? "Time to build your habit!"
    }

    // MARK: - Notification Categories

    func setupNotificationCategories() {
        // Habit reminder actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_HABIT",
            title: "Mark Complete",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_REMINDER",
            title: "Snooze 1 hour",
            options: []
        )

        let habitCategory = UNNotificationCategory(
            identifier: "HABIT_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Daily entry actions
        let openAction = UNNotificationAction(
            identifier: "OPEN_DAILY_ENTRY",
            title: "Log Now",
            options: [.foreground]
        )

        let dailyCategory = UNNotificationCategory(
            identifier: "DAILY_ENTRY",
            actions: [openAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Streak celebration
        let shareAction = UNNotificationAction(
            identifier: "SHARE_STREAK",
            title: "Share",
            options: [.foreground]
        )

        let streakCategory = UNNotificationCategory(
            identifier: "STREAK_CELEBRATION",
            actions: [shareAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            habitCategory,
            dailyCategory,
            streakCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
        case "COMPLETE_HABIT":
            // Handle marking habit complete
            if let habitIdString = response.notification.request.content.userInfo["habitId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("CompleteHabitFromNotification"),
                    object: nil,
                    userInfo: ["habitId": habitIdString]
                )
            }

        case "SNOOZE_REMINDER":
            // Reschedule notification for 1 hour later
            let content = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let request = UNNotificationRequest(
                identifier: response.notification.request.identifier + "-snoozed",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)

        case "OPEN_DAILY_ENTRY":
            NotificationCenter.default.post(
                name: Notification.Name("OpenDailyEntry"),
                object: nil
            )

        case "SHARE_STREAK":
            NotificationCenter.default.post(
                name: Notification.Name("ShareStreak"),
                object: nil,
                userInfo: response.notification.request.content.userInfo
            )

        default:
            break
        }

        completionHandler()
    }
}
