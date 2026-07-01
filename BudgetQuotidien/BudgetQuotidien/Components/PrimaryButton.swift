import SwiftUI

/// Bouton d'action principale (plein, vert) avec haptique et animation d'appui.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = AppColor.positive
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.impact(.medium)
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).font(AppFont.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                    .fill(tint.gradient)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

/// Bouton secondaire (texte teinté).
struct SecondaryButton: View {
    let title: String
    var tint: Color = AppColor.positive
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Text(title)
                .font(AppFont.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(tint)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Style d'appui : léger enfoncement + estompage.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
