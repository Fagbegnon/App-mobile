import SwiftUI

/// Petite carte statistique : icône, libellé, valeur.
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: Color = AppColor.info

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Text(value)
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

/// Ligne clé/valeur pour les listes de récapitulatif.
struct StatRow: View {
    let title: String
    let value: String
    var valueColor: Color = AppColor.textPrimary

    var body: some View {
        HStack {
            Text(title).font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value).font(AppFont.headline).foregroundStyle(valueColor)
        }
        .padding(.vertical, 6)
    }
}
