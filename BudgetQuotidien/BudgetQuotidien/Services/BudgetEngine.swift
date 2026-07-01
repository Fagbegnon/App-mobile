import Foundation
import SwiftData

/// Regroupement de dépenses pour un jour donné.
struct DayGroup: Identifiable {
    var day: Date
    var items: [Expense]
    var id: Date { day }
    var total: Double { items.reduce(0) { $0 + $1.amount } }
}

/// Total dépensé pour une catégorie.
struct CategoryTotal: Identifiable {
    var category: ExpenseCategory
    var total: Double
    var id: ExpenseCategory { category }
}

/// Point de la courbe d'évolution du budget restant.
struct RemainingPoint: Identifiable {
    var date: Date
    var remaining: Double
    var id: Date { date }
}

/// Fait le pont entre le modèle SwiftData `Budget` et le moteur pur `BudgetCalculator`.
enum BudgetEngine {

    /// Instantané courant d'un budget SwiftData.
    static func snapshot(for budget: Budget, today: Date = .now) -> BudgetSnapshot {
        BudgetCalculator.snapshot(
            initialAmount: budget.initialAmount,
            incomes: budget.incomes.map { (amount: $0.amount, date: $0.date) },
            expenses: budget.expenses.map { (amount: $0.amount, date: $0.date) },
            start: budget.startDate,
            end: budget.endDate,
            today: today
        )
    }

    /// Dépenses d'un jour donné, triées de la plus récente à la plus ancienne.
    static func expenses(of budget: Budget, on day: Date, calendar: Calendar = .current) -> [Expense] {
        budget.expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date > $1.date }
    }

    /// Regroupe les dépenses par jour (clé = début du jour), triées récent → ancien.
    static func groupedByDay(_ expenses: [Expense], calendar: Calendar = .current) -> [DayGroup] {
        let groups = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.date) }
        return groups
            .map { DayGroup(day: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }

    /// Total dépensé par catégorie, trié décroissant.
    static func totalsByCategory(_ expenses: [Expense]) -> [CategoryTotal] {
        var totals: [ExpenseCategory: Double] = [:]
        for e in expenses { totals[e.category, default: 0] += e.amount }
        return totals
            .map { CategoryTotal(category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    /// Cumul dépensé jour après jour (pour la courbe d'évolution du budget restant).
    static func dailyRemainingCurve(for budget: Budget, today: Date = .now, calendar: Calendar = .current) -> [RemainingPoint] {
        let total = budget.totalBudget
        let start = budget.startDate
        let days = BudgetCalculator.totalDays(start: budget.startDate, end: budget.endDate)
        var running = total
        var byDay: [Date: Double] = [:]
        for e in budget.expenses {
            byDay[calendar.startOfDay(for: e.date), default: 0] += e.amount
        }
        var curve: [RemainingPoint] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            running -= (byDay[calendar.startOfDay(for: day)] ?? 0)
            curve.append(RemainingPoint(date: day, remaining: running))
            if calendar.startOfDay(for: day) >= calendar.startOfDay(for: today) { break }
        }
        return curve
    }

    /// Nombre de jours respectés / dépassés sur la période écoulée.
    static func respectedDays(for budget: Budget, upTo day: Date = .now, calendar: Calendar = .current) -> (respected: Int, exceeded: Int) {
        var respected = 0
        var exceeded = 0
        let end = min(calendar.startOfDay(for: day), budget.endDate)
        var cursor = budget.startDate
        while cursor <= end {
            // Budget conseillé « figé » de départ comme référence de respect.
            let reference = budget.totalBudget / Double(BudgetCalculator.totalDays(start: budget.startDate, end: budget.endDate))
            let spent = BudgetCalculator.spent(on: cursor, expenses: budget.expenses.map { (amount: $0.amount, date: $0.date) }, calendar: calendar)
            if spent > reference { exceeded += 1 } else { respected += 1 }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return (respected, exceeded)
    }
}
