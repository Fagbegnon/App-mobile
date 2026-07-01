import SwiftUI

/// Catégories de dépenses avec icône SF Symbol et couleur associée.
enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Alimentation"
    case transport = "Transport"
    case bills = "Factures"
    case leisure = "Loisirs"
    case health = "Santé"
    case shopping = "Shopping"
    case education = "Éducation"
    case other = "Autres"

    var id: String { rawValue }

    var label: String { rawValue }

    var systemImage: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .bills: return "bolt.fill"
        case .leisure: return "gamecontroller.fill"
        case .health: return "cross.case.fill"
        case .shopping: return "bag.fill"
        case .education: return "book.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .food: return .green
        case .transport: return .blue
        case .bills: return .orange
        case .leisure: return .purple
        case .health: return .pink
        case .shopping: return .teal
        case .education: return .indigo
        case .other: return .gray
        }
    }

    /// Sous-catégories suggérées (facultatives).
    var suggestions: [String] {
        switch self {
        case .food: return ["Restaurant", "Marché", "Supermarché", "Café"]
        case .transport: return ["Taxi", "Essence", "Bus", "Moto"]
        case .bills: return ["Électricité", "Eau", "Internet", "Loyer"]
        case .leisure: return ["Cinéma", "Sortie", "Sport", "Streaming"]
        case .health: return ["Pharmacie", "Consultation", "Analyses"]
        case .shopping: return ["Vêtements", "Électronique", "Maison"]
        case .education: return ["Livres", "Frais", "Cours"]
        case .other: return []
        }
    }
}
