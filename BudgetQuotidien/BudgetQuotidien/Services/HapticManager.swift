import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Retour haptique centralisé.
enum HapticManager {
    #if canImport(UIKit)
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
        g.impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #else
    static func impact(_ style: Int = 0) {}
    static func success() {}
    static func warning() {}
    static func error() {}
    static func selection() {}
    #endif
}
