import SwiftUI
import SwiftData

/// Profil & Paramètres.
struct ProfileView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @State private var settings = AppSettings.shared
    @State private var showNewBudget = false
    @State private var showAddIncome = false

    var body: some View {
        NavigationStack {
            List {
                Section("Général") {
                    NavigationLink { StatisticsView(budget: budget).navigationTitle("Statistiques") } label: {
                        settingRow("chart.pie.fill", "Statistiques", AppColor.info)
                    }
                    HStack {
                        settingRow("coloncurrencysign.circle.fill", "Devise", AppColor.positive)
                        Spacer()
                        Text(CurrencyFormatter.symbol(for: budget.currencyCode))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    Toggle(isOn: $settings.notificationsEnabled) {
                        settingRow("bell.fill", "Notifications", AppColor.warning)
                    }
                    .onChange(of: settings.notificationsEnabled) { _, _ in
                        NotificationManager.shared.refreshSchedule(settings: settings)
                    }
                }

                Section("Budget") {
                    NavigationLink { MonthlySummaryView(budget: budget) } label: {
                        settingRow("trophy.fill", "Résumé mensuel", AppColor.warning)
                    }
                    Button { showAddIncome = true } label: {
                        settingRow("plus.circle.fill", "Ajouter de l'argent", AppColor.positive)
                    }
                    Button { showNewBudget = true } label: {
                        settingRow("arrow.triangle.2.circlepath", "Nouveau budget", AppColor.info)
                    }
                }

                Section("Sécurité") {
                    Toggle(isOn: $settings.appLockEnabled) {
                        settingRow("lock.fill", "Code de verrouillage", AppColor.textSecondary)
                    }
                    Toggle(isOn: $settings.faceIDEnabled) {
                        settingRow("faceid", "Face ID", AppColor.info)
                    }
                }

                Section {
                    HStack {
                        Text("Version").foregroundStyle(AppColor.textSecondary)
                        Spacer()
                        Text("1.0.0").foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Profil")
            .sheet(isPresented: $showNewBudget) {
                BudgetSetupView(isFirstBudget: false)
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(budget: budget)
            }
        }
    }

    private func settingRow(_ icon: String, _ title: String, _ tint: Color) -> some View {
        HStack(spacing: AppMetrics.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 8).fill(tint))
            Text(title).foregroundStyle(AppColor.textPrimary)
        }
    }
}
