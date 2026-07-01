import SwiftUI

/// Alerte modale de dépassement du budget journalier (écran 9).
struct OverspendAlertView: View {
    let amount: Double
    let currency: String
    let onDetails: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: AppMetrics.spacingM) {
                ZStack {
                    Circle().fill(AppColor.dangerSoft).frame(width: 72, height: 72)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColor.danger)
                }
                .padding(.top, AppMetrics.spacingS)

                Text("Budget dépassé !")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Vous avez dépassé votre budget journalier de")
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)

                Text(CurrencyFormatter.string(amount, code: currency))
                    .font(AppFont.amount())
                    .foregroundStyle(AppColor.danger)

                VStack(spacing: AppMetrics.spacingS) {
                    PrimaryButton(title: "Voir les détails", tint: AppColor.danger) { onDetails() }
                    SecondaryButton(title: "OK", tint: AppColor.textSecondary) { onDismiss() }
                }
                .padding(.top, AppMetrics.spacingS)
            }
            .padding(AppMetrics.spacingL)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppColor.surface)
            )
            .softShadow(radius: 30, y: 10)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    OverspendAlertView(amount: 2500, currency: "XOF", onDetails: {}, onDismiss: {})
}
