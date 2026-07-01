import SwiftUI
import SwiftData
import Charts

/// Statistiques : répartition des dépenses par catégorie (donut) + liste détaillée.
struct StatisticsView: View {
    let budget: Budget

    private var currency: String { budget.currencyCode }
    private var totals: [CategoryTotal] {
        BudgetEngine.totalsByCategory(budget.expenses)
    }
    private var grandTotal: Double { totals.reduce(0) { $0 + $1.total } }

    var body: some View {
        ScrollView {
            VStack(spacing: AppMetrics.spacingL) {
                if totals.isEmpty {
                    ContentUnavailableView("Aucune donnée", systemImage: "chart.pie",
                        description: Text("Ajoutez des dépenses pour voir vos statistiques."))
                        .padding(.top, 80)
                } else {
                    donutCard
                    categoryList
                }
            }
            .padding(AppMetrics.screenPadding)
        }
        .background(AppColor.background)
    }

    private var donutCard: some View {
        VStack {
            Chart(totals) { item in
                SectorMark(
                    angle: .value("Montant", item.total),
                    innerRadius: .ratio(0.62),
                    angularInset: 2
                )
                .cornerRadius(4)
                .foregroundStyle(item.category.tint)
            }
            .frame(height: 220)
            .overlay {
                VStack(spacing: 2) {
                    Text(CurrencyFormatter.string(grandTotal, code: currency, showSymbol: false))
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("Total")
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .card()
    }

    private var categoryList: some View {
        VStack(spacing: 0) {
            ForEach(totals, id: \.category) { item in
                HStack(spacing: AppMetrics.spacingM) {
                    CategoryIcon(systemImage: item.category.systemImage, tint: item.category.tint, size: 36)
                    Text(item.category.label).foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Text(CurrencyFormatter.string(item.total, code: currency))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(percent(item.total))
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 44, alignment: .trailing)
                }
                .padding(.vertical, 10)
                if item.category != totals.last?.category { Divider() }
            }
        }
        .card()
    }

    private func percent(_ value: Double) -> String {
        guard grandTotal > 0 else { return "0%" }
        return "\(Int((value / grandTotal * 100).rounded()))%"
    }
}
