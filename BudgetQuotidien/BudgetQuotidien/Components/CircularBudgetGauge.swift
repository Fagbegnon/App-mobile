import SwiftUI

/// Jauge circulaire indiquant le pourcentage du budget quotidien consommé.
/// Affiche au centre le solde restant du jour.
struct CircularBudgetGauge: View {
    /// Fraction consommée (0…1+, peut dépasser 1 => rouge).
    let consumption: Double
    let centerValue: Double
    let caption: String
    let currency: String
    let status: BudgetStatus

    @State private var animatedProgress: Double = 0

    private var clamped: Double { min(max(consumption, 0), 1) }

    private var ringColor: Color {
        switch status {
        case .healthy: return AppColor.positive
        case .warning: return AppColor.warning
        case .over: return AppColor.danger
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.separator, lineWidth: 16)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    ringColor.gradient,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.smooth(duration: 0.9), value: animatedProgress)

            VStack(spacing: 2) {
                Text(caption)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                Text(CurrencyFormatter.string(max(centerValue, 0), code: currency, showSymbol: false))
                    .font(AppFont.hero())
                    .foregroundStyle(centerValue < 0 ? AppColor.danger : AppColor.textPrimary)
                    .contentTransition(.numericText(value: centerValue))
                    .animation(.smooth, value: centerValue)
                Text(CurrencyFormatter.symbol(for: currency))
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear { animatedProgress = clamped }
        .onChange(of: consumption) { _, _ in animatedProgress = clamped }
    }
}

#Preview {
    CircularBudgetGauge(
        consumption: 0.35,
        centerValue: 6500,
        caption: "Reste aujourd'hui",
        currency: "XOF",
        status: .healthy
    )
    .padding()
}
