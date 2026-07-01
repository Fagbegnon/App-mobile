import Foundation
import SwiftData

/// Argent ajouté au budget (salaire, prime, vente…).
@Model
final class Income {
    var id: UUID
    var amount: Double
    var typeRaw: String
    var details: String?
    var date: Date
    var createdAt: Date

    var budget: Budget?

    init(
        id: UUID = UUID(),
        amount: Double,
        type: IncomeType,
        details: String? = nil,
        date: Date = .now,
        createdAt: Date = .now,
        budget: Budget? = nil
    ) {
        self.id = id
        self.amount = amount
        self.typeRaw = type.rawValue
        self.details = details
        self.date = date
        self.createdAt = createdAt
        self.budget = budget
    }
}

extension Income {
    var type: IncomeType {
        get { IncomeType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }
}
