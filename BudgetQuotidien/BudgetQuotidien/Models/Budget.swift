import Foundation
import SwiftData

/// Budget mensuel actif. Un seul budget est `isActive` à la fois.
@Model
final class Budget {
    var id: UUID
    var initialAmount: Double
    var startDate: Date
    var endDate: Date
    var currencyCode: String
    var createdAt: Date
    var isActive: Bool

    /// Dépenses rattachées à ce budget.
    @Relationship(deleteRule: .cascade, inverse: \Expense.budget)
    var expenses: [Expense]

    /// Revenus (argent ajouté) rattachés à ce budget.
    @Relationship(deleteRule: .cascade, inverse: \Income.budget)
    var incomes: [Income]

    init(
        id: UUID = UUID(),
        initialAmount: Double,
        startDate: Date,
        endDate: Date,
        currencyCode: String = "XOF",
        createdAt: Date = .now,
        isActive: Bool = true
    ) {
        self.id = id
        self.initialAmount = initialAmount
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = Calendar.current.startOfDay(for: endDate)
        self.currencyCode = currencyCode
        self.createdAt = createdAt
        self.isActive = isActive
        self.expenses = []
        self.incomes = []
    }
}

// MARK: - Dérivés pratiques
extension Budget {
    /// Total de l'argent ajouté après la création.
    var totalIncome: Double { incomes.reduce(0) { $0 + $1.amount } }

    /// Budget total disponible = initial + revenus.
    var totalBudget: Double { initialAmount + totalIncome }

    /// Total dépensé sur toute la période.
    var totalSpent: Double { expenses.reduce(0) { $0 + $1.amount } }

    /// Budget restant à ce jour.
    var remainingBudget: Double { totalBudget - totalSpent }
}
