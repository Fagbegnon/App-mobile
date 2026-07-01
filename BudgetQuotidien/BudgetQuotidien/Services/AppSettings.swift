import SwiftUI

/// Préférences utilisateur persistées (léger, hors SwiftData).
@Observable
final class AppSettings {
    static let shared = AppSettings()

    private enum Keys {
        static let onboarded = "hasCompletedOnboarding"
        static let currency = "preferredCurrency"
        static let notifications = "notificationsEnabled"
        static let lockEnabled = "appLockEnabled"
        static let faceID = "faceIDEnabled"
        static let dailyReminderHour = "dailyReminderHour"
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarded) }
    }
    var preferredCurrency: String {
        didSet { UserDefaults.standard.set(preferredCurrency, forKey: Keys.currency) }
    }
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notifications) }
    }
    var appLockEnabled: Bool {
        didSet { UserDefaults.standard.set(appLockEnabled, forKey: Keys.lockEnabled) }
    }
    var faceIDEnabled: Bool {
        didSet { UserDefaults.standard.set(faceIDEnabled, forKey: Keys.faceID) }
    }
    /// Heure du rappel « pas encore de dépense » (par défaut 20h).
    var dailyReminderHour: Int {
        didSet { UserDefaults.standard.set(dailyReminderHour, forKey: Keys.dailyReminderHour) }
    }

    private init() {
        let d = UserDefaults.standard
        hasCompletedOnboarding = d.bool(forKey: Keys.onboarded)
        preferredCurrency = d.string(forKey: Keys.currency) ?? "XOF"
        notificationsEnabled = d.object(forKey: Keys.notifications) as? Bool ?? true
        appLockEnabled = d.bool(forKey: Keys.lockEnabled)
        faceIDEnabled = d.bool(forKey: Keys.faceID)
        dailyReminderHour = d.object(forKey: Keys.dailyReminderHour) as? Int ?? 20
    }
}
