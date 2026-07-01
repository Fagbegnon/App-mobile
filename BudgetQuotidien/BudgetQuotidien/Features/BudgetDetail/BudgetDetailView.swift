import SwiftUI
import SwiftData
import Charts

/// Vue « Budget du mois » : vue d'ensemble + courbe d'évolution du budget restant.
struct BudgetDetailView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @State private var showAddIncome = false

    private var currency: String { budget.currencyCode }
    private var snap: BudgetSnapshot { BudgetEngine.snapshot(for: budget) }
    private var curve: [RemainingPoint] { BudgetEngine.dailyRemainingCurve(for: budget) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppMetrics.spacingL) {
                    overviewCard
                    evolutionCard
                }
                .padding(AppMetrics.screenPadding)
            }
            .background(AppColor.background)
            .navigationTitle("Budget du mois")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.impact(.light)
                        showAddIncome = true
                    } label: {
                        Label("Ajouter", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(budget: budget)
            }
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
            Text("Vue d'ensemble")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            StatRow(title: "Budget initial", value: CurrencyFormatter.string(snap.initialAmount, code: currency))
            Divider()
            StatRow(title: "Argent ajouté",
                    value: "+ \(CurrencyFormatter.string(snap.totalIncome, code: currency))",
                    valueColor: AppColor.positive)
            Divider()
            StatRow(title: "Budget total", value: CurrencyFormatter.string(snap.totalBudget, code: currency))
            Divider()
            StatRow(title: "Total dépensé",
                    value: CurrencyFormatter.string(snap.totalSpent, code: currency),
                    valueColor: AppColor.danger)
            Divider()
            StatRow(title: "Budget restant",
                    value: CurrencyFormatter.string(snap.remainingBudget, code: currency),
                    valueColor: snap.remainingBudget < 0 ? AppColor.danger : AppColor.positive)
        }
        .card()
    }

    private var evolutionCard: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingM) {
            Text("Évolution du budget")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            if curve.count < 2 {
                Text("Pas encore assez de données pour tracer une courbe.")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(height: 180)
            } else {
                Chart(curve) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Restant", point.remaining)
                    )
                    .foregroundStyle(
                        .linearGradient(colors: [AppColor.positive.opacity(0.3), .clear],
                                        startPoint: .top, endPoint: .bottom)
                    )
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Restant", point.remaining)
                    )
                    .foregroundStyle(AppColor.positive)
                    .interpolationMethod(.catmullRom)
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(CurrencyFormatter.compact(v))
                            }
                        }
                    }
                }
                .frame(height: 220)
            }
        }
        .card()
    }
}
