import Foundation
import UserNotifications

/// Gère les notifications locales : dépassement, seuil 20 %, rappel 20h, résumé du soir.
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    // MARK: Autorisation

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: Notifications immédiates (réactives)

    /// Budget quotidien dépassé.
    func notifyDailyOverspent(by amount: Double, currency: String) {
        push(
            id: "daily-over",
            title: "Budget dépassé !",
            body: "Vous avez dépassé votre budget journalier de \(CurrencyFormatter.string(amount, code: currency)).",
            after: 1
        )
    }

    /// Il reste moins de 20 % du budget du jour.
    func notifyLowDailyRemaining(remaining: Double, currency: String) {
        push(
            id: "daily-low",
            title: "Attention à votre budget",
            body: "Il ne vous reste que \(CurrencyFormatter.string(remaining, code: currency)) pour aujourd'hui.",
            after: 1
        )
    }

    // MARK: Notifications planifiées (récurrentes)

    /// Rappel « aucune dépense enregistrée » à l'heure choisie (par défaut 20h).
    func scheduleDailyReminder(hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "N'oubliez pas de suivre vos dépenses"
        content.body = "Enregistrez vos dépenses du jour pour garder le contrôle de votre budget."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger))
    }

    /// Résumé de fin de journée (21h).
    func scheduleEveningSummary(hour: Int = 21) {
        let content = UNMutableNotificationContent()
        content.title = "Résumé de la journée"
        content.body = "Voici comment s'est passée votre journée côté budget."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: "evening-summary", content: content, trigger: trigger))
    }

    func cancelAll() { center.removeAllPendingNotificationRequests() }

    func refreshSchedule(settings: AppSettings) {
        cancelRecurring()
        guard settings.notificationsEnabled else { return }
        scheduleDailyReminder(hour: settings.dailyReminderHour)
        scheduleEveningSummary()
    }

    private func cancelRecurring() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder", "evening-summary"])
    }

    // MARK: Privé

    private func push(id: String, title: String, body: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
