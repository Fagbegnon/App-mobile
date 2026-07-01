import SwiftUI

/// Moyen de paiement d'une dépense.
enum PaymentMethod: String, CaseIterable, Identifiable, Codable {
    case cash = "Espèces"
    case card = "Carte"
    case mobile = "Mobile Money"
    case transfer = "Virement"

    var id: String { rawValue }
    var label: String { rawValue }

    var systemImage: String {
        switch self {
        case .cash: return "banknote.fill"
        case .card: return "creditcard.fill"
        case .mobile: return "iphone"
        case .transfer: return "arrow.left.arrow.right"
        }
    }
}
