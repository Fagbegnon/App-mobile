import SwiftUI

/// Typographie basée sur SF Pro (police système). Styles Dynamic Type compatibles.
enum AppFont {
    /// Grand nombre mis en avant (montant central).
    static func hero() -> Font { .system(size: 44, weight: .bold, design: .rounded) }
    static func amount() -> Font { .system(size: 34, weight: .bold, design: .rounded) }

    static var largeTitle: Font { .system(.largeTitle, design: .rounded).weight(.bold) }
    static var title: Font { .system(.title2, design: .rounded).weight(.semibold) }
    static var headline: Font { .system(.headline, design: .rounded) }
    static var body: Font { .system(.body) }
    static var callout: Font { .system(.callout) }
    static var subheadline: Font { .system(.subheadline) }
    static var footnote: Font { .system(.footnote) }
    static var caption: Font { .system(.caption) }
}
