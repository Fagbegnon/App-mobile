import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Palette sémantique de l'application, adaptée aux modes clair et sombre.
enum AppColor {
    /// Vert — budget disponible / état sain.
    static let positive = Color(hex: 0x2FB574)
    static let positiveSoft = Color(hex: 0x2FB574).opacity(0.12)

    /// Orange — attention (< 20 % du budget du jour).
    static let warning = Color(hex: 0xF5A623)
    static let warningSoft = Color(hex: 0xF5A623).opacity(0.14)

    /// Rouge — dépassement.
    static let danger = Color(hex: 0xF0524B)
    static let dangerSoft = Color(hex: 0xF0524B).opacity(0.12)

    /// Bleu — informations.
    static let info = Color(hex: 0x3B82F6)
    static let infoSoft = Color(hex: 0x3B82F6).opacity(0.12)

    /// Fond principal (gris très clair en mode clair, presque noir en sombre).
    static let background = Color(light: 0xF4F6F8, dark: 0x0E0F12)

    /// Surface des cartes.
    static let surface = Color(light: 0xFFFFFF, dark: 0x1B1D22)

    /// Séparateurs légers.
    static let separator = Color(light: 0xE7EAEE, dark: 0x2C2F36)

    static let textPrimary = Color(light: 0x101317, dark: 0xF5F6F8)
    static let textSecondary = Color(light: 0x6B7280, dark: 0x9BA1AC)
}

// MARK: - Helpers de couleur

extension Color {
    /// Couleur depuis un hex `0xRRGGBB`.
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// Couleur dynamique clair/sombre.
    init(light: UInt, dark: UInt) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
        #else
        self.init(hex: light)
        #endif
    }
}
