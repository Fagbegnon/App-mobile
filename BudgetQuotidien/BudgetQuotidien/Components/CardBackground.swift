import SwiftUI

/// Fond de carte réutilisable : surface, coins arrondis, ombre douce.
struct CardBackground: ViewModifier {
    var padding: CGFloat = AppMetrics.cardPadding
    var radius: CGFloat = AppMetrics.cardRadius
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppColor.surface)
            )
            .softShadow()
    }
}

extension View {
    func card(padding: CGFloat = AppMetrics.cardPadding, radius: CGFloat = AppMetrics.cardRadius) -> some View {
        modifier(CardBackground(padding: padding, radius: radius))
    }
}
