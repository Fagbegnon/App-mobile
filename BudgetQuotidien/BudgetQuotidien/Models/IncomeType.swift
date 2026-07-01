import SwiftUI

/// Type d'argent ajouté.
enum IncomeType: String, CaseIterable, Identifiable, Codable {
    case salary = "Salaire"
    case bonus = "Prime"
    case refund = "Remboursement"
    case sale = "Vente"
    case other = "Autre"

    var id: String { rawValue }
    var label: String { rawValue }

    var systemImage: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .bonus: return "gift.fill"
        case .refund: return "arrow.uturn.backward.circle.fill"
        case .sale: return "tag.fill"
        case .other: return "plus.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .salary: return .green
        case .bonus: return .orange
        case .refund: return .blue
        case .sale: return .teal
        case .other: return .gray
        }
    }
}
