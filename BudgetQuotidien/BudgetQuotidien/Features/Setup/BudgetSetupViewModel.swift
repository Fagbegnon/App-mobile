import Foundation
import SwiftData

/// Logique de l'écran de configuration d'un nouveau budget.
@Observable
final class BudgetSetupViewModel {
    var initialAmount: Double = 0
    var startDate: Date = Calendar.current.startOfDay(for: .now)
    var endDate: Date = {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        // Par défaut : fin du mois courant.
        let range = cal.range(of: .day, in: .month, for: start)?.count ?? 30
        let comps = cal.dateComponents([.year, .month], from: start)
        var end = cal.date(from: comps) ?? start
        end = cal.date(byAdding: .day, value: range - 1, to: end) ?? start
        return end
    }()
    var currencyCode: String = AppSettings.shared.preferredCurrency

    /// Nombre de jours de la période.
    var totalDays: Int {
        BudgetCalculator.totalDays(start: startDate, end: endDate)
    }

    /// Budget quotidien cible (calculé automatiquement).
    var dailyTarget: Double {
        guard totalDays > 0 else { return 0 }
        return initialAmount / Double(totalDays)
    }

    var isValid: Bool {
        initialAmount > 0 && endDate >= startDate
    }

    /// Crée le budget, désactive les anciens et le renvoie.
    @discardableResult
    func createBudget(in context: ModelContext) -> Budget? {
        guard isValid else { return nil }

        // Désactiver tout budget actif existant.
        let descriptor = FetchDescriptor<Budget>(predicate: #Predicate { $0.isActive })
        if let actives = try? context.fetch(descriptor) {
            for b in actives { b.isActive = false }
        }

        let budget = Budget(
            initialAmount: initialAmount,
            startDate: startDate,
            endDate: endDate,
            currencyCode: currencyCode,
            isActive: true
        )
        context.insert(budget)
        try? context.save()

        AppSettings.shared.preferredCurrency = currencyCode
        return budget
    }
}
