import SwiftUI

/// Constantes de mise en page : rayons, espacements, ombres.
enum AppMetrics {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    static let cardRadius: CGFloat = 20
    static let controlRadius: CGFloat = 14
    static let pillRadius: CGFloat = 999

    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
}

/// Ombre douce façon Apple pour les cartes.
struct SoftShadow: ViewModifier {
    var radius: CGFloat = 16
    var y: CGFloat = 8
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.06), radius: radius, x: 0, y: y)
    }
}

extension View {
    func softShadow(radius: CGFloat = 16, y: CGFloat = 8) -> some View {
        modifier(SoftShadow(radius: radius, y: y))
    }
}
