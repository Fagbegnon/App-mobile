import Foundation
import SwiftData

/// Logique de saisie d'une dépense.
@Observable
final class AddExpenseViewModel {
    var amount: Double = 0
    var category: ExpenseCategory = .food
    var subcategory: String = ""
    var details: String = ""
    var notes: String = ""
    var paymentMethod: PaymentMethod = .cash
    var date: Date = .now

    var isValid: Bool { amount > 0 }

    /// Enregistre la dépense et met à jour le budget.
    @discardableResult
    func save(to budget: Budget, in context: ModelContext) -> Bool {
        guard isValid else { return false }
        let expense = Expense(
            amount: amount,
            category: category,
            subcategory: subcategory.isEmpty ? nil : subcategory,
            details: details.isEmpty ? nil : details,
            notes: notes.isEmpty ? nil : notes,
            paymentMethod: paymentMethod,
            date: date,
            budget: budget
        )
        context.insert(expense)
        try? context.save()
        return true
    }
}
