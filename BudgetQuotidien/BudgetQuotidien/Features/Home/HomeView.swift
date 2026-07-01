import SwiftUI
import SwiftData

/// Tableau de bord — « Combien puis-je encore dépenser aujourd'hui ? »
struct HomeView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @State private var vm = HomeViewModel()
    @State private var showAddExpense = false
    @State private var showNotifications = false

    private var currency: String { budget.currencyCode }
    private var snap: BudgetSnapshot { vm.snapshot ?? BudgetEngine.snapshot(for: budget) }

    var body: some View {
        ScrollView {
            VStack(spacing: AppMetrics.spacingL) {
                header
                gaugeCard
                todayRow
                monthCard
                bottomStats
                Color.clear.frame(height: 80) // espace pour le FAB
            }
            .padding(AppMetrics.screenPadding)
        }
        .background(AppColor.background)
        .refreshable { vm.refresh(for: budget) }
        .onAppear { vm.refresh(for: budget) }
        .sheet(isPresented: $showAddExpense, onDismiss: {
            vm.refresh(for: budget)
            vm.evaluateAfterExpense(currency: currency)
        }) {
            AddExpenseView(budget: budget)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        .overlay(alignment: .bottom) { floatingAddButton }
        .overlay {
            if vm.showOverspendAlert {
                OverspendAlertView(
                    amount: max(snap.spentToday - snap.recommendedToday, 0),
                    currency: currency,
                    onDetails: { vm.showOverspendAlert = false; showAddExpense = false },
                    onDismiss: { vm.showOverspendAlert = false }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.showOverspendAlert)
    }

    // MARK: Sous-vues

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Aujourd'hui")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(Date.now, format: .dateTime.day().month(.wide).year())
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppColor.surface))
            }
        }
    }

    private var gaugeCard: some View {
        VStack(spacing: AppMetrics.spacingM) {
            CircularBudgetGauge(
                consumption: snap.dayConsumption,
                centerValue: snap.remainingToday,
                caption: "Reste aujourd'hui",
                currency: currency,
                status: snap.dayStatus
            )
            Text("sur \(CurrencyFormatter.string(snap.recommendedToday, code: currency))")
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: AppMetrics.spacingL)
    }

    private var todayRow: some View {
        HStack(spacing: AppMetrics.spacingM) {
            StatCard(
                icon: "arrow.down.circle.fill",
                title: "Dépensé aujourd'hui",
                value: CurrencyFormatter.string(snap.spentToday, code: currency),
                tint: AppColor.danger
            )
            StatCard(
                icon: "target",
                title: "Conseillé / jour",
                value: CurrencyFormatter.string(snap.recommendedToday, code: currency),
                tint: AppColor.positive
            )
        }
    }

    private var monthCard: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingM) {
            HStack {
                Text("Budget restant du mois")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(CurrencyFormatter.string(snap.remainingBudget, code: currency))
                    .font(AppFont.headline)
                    .foregroundStyle(snap.remainingBudget < 0 ? AppColor.danger : AppColor.positive)
            }
            MonthProgressBar(
                fraction: snap.monthConsumption,
                tint: snap.remainingBudget < 0 ? AppColor.danger : AppColor.positive
            )
            HStack {
                Text("\(CurrencyFormatter.string(snap.totalSpent, code: currency)) dépensés")
                Spacer()
                Text("sur \(CurrencyFormatter.string(snap.totalBudget, code: currency))")
            }
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)
        }
        .card()
    }

    private var bottomStats: some View {
        HStack(spacing: AppMetrics.spacingM) {
            StatCard(
                icon: "calendar",
                title: "Jours restants",
                value: "\(snap.daysRemaining) jours",
                tint: AppColor.info
            )
            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Budget initial / jour",
                value: CurrencyFormatter.string(snap.initialDailyBudget, code: currency),
                tint: AppColor.info
            )
        }
    }

    private var floatingAddButton: some View {
        Button {
            HapticManager.impact(.medium)
            showAddExpense = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Circle().fill(AppColor.positive.gradient))
                .softShadow(radius: 12, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.bottom, AppMetrics.spacingM)
    }
}
