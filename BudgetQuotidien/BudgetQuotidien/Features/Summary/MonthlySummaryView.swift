import SwiftUI
import SwiftData

/// Résumé mensuel : bilan, taux de réussite, économies, jours respectés/dépassés.
struct MonthlySummaryView: View {
    let budget: Budget

    private var currency: String { budget.currencyCode }
    private var snap: BudgetSnapshot { BudgetEngine.snapshot(for: budget) }
    private var days: (respected: Int, exceeded: Int) { BudgetEngine.respectedDays(for: budget) }

    private var totalTrackedDays: Int { max(days.respected + days.exceeded, 1) }
    private var successRate: Int { Int((Double(days.respected) / Double(totalTrackedDays) * 100).rounded()) }
    private var savings: Double { max(snap.remainingBudget, 0) }

    var body: some View {
        ScrollView {
            VStack(spacing: AppMetrics.spacingL) {
                trophyCard
                metricsGrid
                breakdownCard
                shareButton
            }
            .padding(AppMetrics.screenPadding)
        }
        .background(AppColor.background)
        .navigationTitle("Résumé mensuel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var trophyCard: some View {
        VStack(spacing: AppMetrics.spacingM) {
            Image(systemName: successRate >= 70 ? "trophy.fill" : "flag.checkered")
                .font(.system(size: 56))
                .foregroundStyle(AppColor.warning.gradient)
                .symbolEffect(.bounce, options: .nonRepeating)
            Text(successRate >= 70 ? "Bravo !" : "Continuez !")
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.textPrimary)
            Text(successRate >= 70
                 ? "Vous avez bien géré votre budget ce mois-ci."
                 : "Chaque jour compte pour améliorer votre gestion.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .card(padding: AppMetrics.spacingL)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: AppMetrics.spacingM) {
            StatCard(icon: "percent", title: "Taux de réussite", value: "\(successRate)%", tint: AppColor.positive)
            StatCard(icon: "calendar.badge.checkmark", title: "Jours respectés",
                     value: "\(days.respected)/\(totalTrackedDays)", tint: AppColor.info)
            StatCard(icon: "banknote.fill", title: "Économisé",
                     value: CurrencyFormatter.string(savings, code: currency), tint: AppColor.positive)
            StatCard(icon: "exclamationmark.circle.fill", title: "Jours dépassés",
                     value: "\(days.exceeded)", tint: AppColor.danger)
        }
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Détails").font(AppFont.headline).foregroundStyle(AppColor.textPrimary)
                .padding(.bottom, AppMetrics.spacingS)
            StatRow(title: "Budget initial", value: CurrencyFormatter.string(snap.initialAmount, code: currency))
            Divider()
            StatRow(title: "Argent ajouté", value: CurrencyFormatter.string(snap.totalIncome, code: currency),
                    valueColor: AppColor.positive)
            Divider()
            StatRow(title: "Total dépensé", value: CurrencyFormatter.string(snap.totalSpent, code: currency),
                    valueColor: AppColor.danger)
            Divider()
            StatRow(title: "Économies réalisées", value: CurrencyFormatter.string(savings, code: currency),
                    valueColor: AppColor.positive)
        }
        .card()
    }

    private var shareButton: some View {
        ShareLink(item: shareText) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Partager le rapport").font(AppFont.headline)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .foregroundStyle(AppColor.positive)
        }
    }

    private var shareText: String {
        """
        Mon résumé budget :
        • Taux de réussite : \(successRate)%
        • Jours respectés : \(days.respected)/\(totalTrackedDays)
        • Économisé : \(CurrencyFormatter.string(savings, code: currency))
        """
    }
}
