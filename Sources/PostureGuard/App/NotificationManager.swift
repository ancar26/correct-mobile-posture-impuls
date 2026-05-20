import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func sendPostureAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Lift your phone"
        content.body = "You've been holding your phone too low. Raise it to eye level and relax your neck."
        content.sound = .default

        // Fire immediately, don't repeat
        let request = UNNotificationRequest(
            identifier: "posture.alert",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["posture.alert"])
        UNUserNotificationCenter.current().add(request)
    }
}
