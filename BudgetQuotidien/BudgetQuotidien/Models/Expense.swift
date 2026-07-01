import Foundation
import SwiftData

/// Une dépense unitaire.
@Model
final class Expense {
    var id: UUID
    var amount: Double
    /// Stocké en `rawValue` pour rester stable dans SwiftData.
    var categoryRaw: String
    var subcategory: String?
    var details: String?
    var notes: String?
    var paymentMethodRaw: String
    var date: Date
    var createdAt: Date

    var budget: Budget?

    init(
        id: UUID = UUID(),
        amount: Double,
        category: ExpenseCategory,
        subcategory: String? = nil,
        details: String? = nil,
        notes: String? = nil,
        paymentMethod: PaymentMethod = .cash,
        date: Date = .now,
        createdAt: Date = .now,
        budget: Budget? = nil
    ) {
        self.id = id
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.subcategory = subcategory
        self.details = details
        self.notes = notes
        self.paymentMethodRaw = paymentMethod.rawValue
        self.date = date
        self.createdAt = createdAt
        self.budget = budget
    }
}

extension Expense {
    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var paymentMethod: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethodRaw) ?? .cash }
        set { paymentMethodRaw = newValue.rawValue }
    }
}
