import Foundation

/// Formatage des montants selon la devise (FCFA / XOF par défaut).
enum CurrencyFormatter {

    /// Formate un montant : `6 500 FCFA`. Sans décimales pour les devises entières (XOF).
    static func string(_ amount: Double, code: String = "XOF", showSymbol: Bool = true) -> String {
        let value = number(amount, code: code)
        guard showSymbol else { return value }
        return "\(value) \(symbol(for: code))"
    }

    /// Version compacte pour les axes de graphiques : `300K`, `1,2M`.
    static func compact(_ amount: Double) -> String {
        let abs = Swift.abs(amount)
        switch abs {
        case 1_000_000...:
            return trim(amount / 1_000_000) + "M"
        case 1_000...:
            return trim(amount / 1_000) + "K"
        default:
            return number(amount, code: "XOF")
        }
    }

    /// Symbole lisible de la devise.
    static func symbol(for code: String) -> String {
        switch code.uppercased() {
        case "XOF", "XAF": return "FCFA"
        case "EUR": return "€"
        case "USD": return "$"
        case "GBP": return "£"
        default: return code.uppercased()
        }
    }

    /// Nombre de décimales pertinent selon la devise.
    static func fractionDigits(for code: String) -> Int {
        switch code.uppercased() {
        case "XOF", "XAF", "JPY": return 0
        default: return 2
        }
    }

    // MARK: - Privé

    private static func number(_ amount: Double, code: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = fractionDigits(for: code)
        f.minimumFractionDigits = 0
        return f.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }

    private static func trim(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.decimalSeparator = ","
        f.maximumFractionDigits = 1
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
