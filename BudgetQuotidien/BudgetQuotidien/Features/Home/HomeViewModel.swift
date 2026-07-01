import Foundation
import SwiftData

/// État présenté par l'écran d'accueil, dérivé du budget actif.
@Observable
final class HomeViewModel {
    private(set) var snapshot: BudgetSnapshot?
    var showOverspendAlert = false

    /// Garde-fou pour ne notifier qu'une fois par franchissement de seuil.
    private var didNotifyOver = false
    private var didNotifyLow = false

    func refresh(for budget: Budget?, today: Date = .now) {
        guard let budget else { snapshot = nil; return }
        snapshot = BudgetEngine.snapshot(for: budget, today: today)
    }

    /// À appeler après l'ajout d'une dépense : déclenche alertes & notifications.
    func evaluateAfterExpense(currency: String) {
        guard let snap = snapshot else { return }
        let settings = AppSettings.shared

        switch snap.dayStatus {
        case .over:
            if !didNotifyOver {
                didNotifyOver = true
                showOverspendAlert = true
                HapticManager.error()
                if settings.notificationsEnabled {
                    NotificationManager.shared.notifyDailyOverspent(
                        by: snap.spentToday - snap.recommendedToday,
                        currency: currency
                    )
                }
            }
        case .warning:
            if !didNotifyLow {
                didNotifyLow = true
                HapticManager.warning()
                if settings.notificationsEnabled {
                    NotificationManager.shared.notifyLowDailyRemaining(
                        remaining: snap.remainingToday,
                        currency: currency
                    )
                }
            }
        case .healthy:
            didNotifyOver = false
            didNotifyLow = false
        }
    }

    /// Réinitialise les garde-fous (nouveau jour).
    func resetDailyFlags() {
        didNotifyOver = false
        didNotifyLow = false
    }
}
