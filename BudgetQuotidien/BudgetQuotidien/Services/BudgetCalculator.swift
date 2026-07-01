import Foundation

/// Instantané complet de l'état d'un budget à une date donnée.
/// Toutes les valeurs affichées à l'écran d'accueil en découlent.
struct BudgetSnapshot: Equatable {
    var totalBudget: Double          // initial + revenus
    var totalIncome: Double          // Σ revenus
    var initialAmount: Double
    var totalSpent: Double           // Σ dépenses
    var remainingBudget: Double      // total − dépensé

    var totalDays: Int               // durée de la période (incluse)
    var daysElapsed: Int             // jours écoulés depuis le début (min 0)
    var daysRemaining: Int           // jours restants jusqu'à la fin (incluse)

    var initialDailyBudget: Double   // total / totalDays  (au départ)
    var recommendedToday: Double     // restant / joursRestants  (recalculé)
    var spentToday: Double           // Σ dépenses du jour
    var remainingToday: Double       // recommandé − dépensé aujourd'hui

    /// Fraction du budget du jour consommée (0…1+ ; peut dépasser 1).
    var dayConsumption: Double {
        guard recommendedToday > 0 else { return spentToday > 0 ? 1 : 0 }
        return spentToday / recommendedToday
    }

    /// Fraction du budget mensuel consommée (0…1).
    var monthConsumption: Double {
        guard totalBudget > 0 else { return 0 }
        return min(max(totalSpent / totalBudget, 0), 1)
    }

    /// État de santé du jour, pour la couleur de l'UI.
    var dayStatus: BudgetStatus {
        if spentToday > recommendedToday { return .over }
        if remainingToday <= recommendedToday * 0.2 { return .warning }
        return .healthy
    }
}

enum BudgetStatus {
    case healthy   // vert
    case warning   // orange (< 20 % restant)
    case over      // rouge (dépassé)
}

/// Moteur de calcul **pur** — aucune dépendance à SwiftData ou à l'UI.
/// C'est ici que vit la règle « recalcul quotidien ».
enum BudgetCalculator {

    /// Nombre de jours d'une période, bornes incluses (ex. 1er→31 juillet = 31).
    static func totalDays(start: Date, end: Date, calendar: Calendar = .current) -> Int {
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        let days = calendar.dateComponents([.day], from: s, to: e).day ?? 0
        return max(days + 1, 1)
    }

    /// Jours restants entre `today` et `end`, bornes incluses. Min 1 (jamais division par 0).
    static func daysRemaining(from today: Date, end: Date, calendar: Calendar = .current) -> Int {
        let t = calendar.startOfDay(for: today)
        let e = calendar.startOfDay(for: end)
        let days = calendar.dateComponents([.day], from: t, to: e).day ?? 0
        return max(days + 1, 1)
    }

    /// Jours écoulés depuis le début (0 le premier jour).
    static func daysElapsed(from start: Date, to today: Date, calendar: Calendar = .current) -> Int {
        let s = calendar.startOfDay(for: start)
        let t = calendar.startOfDay(for: today)
        let days = calendar.dateComponents([.day], from: s, to: t).day ?? 0
        return max(days, 0)
    }

    /// Somme des dépenses tombant le même jour que `day`.
    static func spent(on day: Date, expenses: [(amount: Double, date: Date)], calendar: Calendar = .current) -> Double {
        expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.amount }
    }

    /// Construit l'instantané complet à `today`.
    static func snapshot(
        initialAmount: Double,
        incomes: [(amount: Double, date: Date)],
        expenses: [(amount: Double, date: Date)],
        start: Date,
        end: Date,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> BudgetSnapshot {
        let totalIncome = incomes.reduce(0) { $0 + $1.amount }
        let totalBudget = initialAmount + totalIncome
        let totalSpent = expenses.reduce(0) { $0 + $1.amount }
        let remaining = totalBudget - totalSpent

        let total = totalDays(start: start, end: end, calendar: calendar)
        let elapsed = daysElapsed(from: start, to: today, calendar: calendar)
        let remainingDays = daysRemaining(from: max(today, start), end: end, calendar: calendar)

        let initialDaily = totalBudget / Double(total)
        // Cœur de la règle : on répartit ce qu'il reste sur les jours qu'il reste.
        let recommended = max(remaining, 0) / Double(remainingDays)
        let spentToday = spent(on: today, expenses: expenses, calendar: calendar)
        let remainingToday = recommended - spentToday

        return BudgetSnapshot(
            totalBudget: totalBudget,
            totalIncome: totalIncome,
            initialAmount: initialAmount,
            totalSpent: totalSpent,
            remainingBudget: remaining,
            totalDays: total,
            daysElapsed: elapsed,
            daysRemaining: remainingDays,
            initialDailyBudget: initialDaily,
            recommendedToday: recommended,
            spentToday: spentToday,
            remainingToday: remainingToday
        )
    }
}
