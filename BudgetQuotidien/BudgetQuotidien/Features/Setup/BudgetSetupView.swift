import SwiftUI
import SwiftData

/// Configuration d'un nouveau budget mensuel.
struct BudgetSetupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var vm = BudgetSetupViewModel()
    var isFirstBudget: Bool = true
    var onCreated: (() -> Void)? = nil

    private let currencies = ["XOF", "XAF", "EUR", "USD"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppMetrics.spacingL) {
                    field(title: "Budget de départ") {
                        HStack {
                            TextField("300 000", value: $vm.initialAmount, format: .number)
                                .keyboardType(.numberPad)
                                .font(AppFont.title)
                            Text(CurrencyFormatter.symbol(for: vm.currencyCode))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }

                    field(title: "Devise") {
                        Picker("Devise", selection: $vm.currencyCode) {
                            ForEach(currencies, id: \.self) { code in
                                Text("\(CurrencyFormatter.symbol(for: code)) — \(code)").tag(code)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    field(title: "Date de début") {
                        DatePicker("", selection: $vm.startDate, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    field(title: "Date de fin") {
                        DatePicker("", selection: $vm.endDate, in: vm.startDate..., displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    dailyTargetCard
                }
                .padding(AppMetrics.screenPadding)
            }
            .background(AppColor.background)
            .navigationTitle("Nouveau budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isFirstBudget {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { dismiss() }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Créer mon budget", systemImage: "checkmark", isEnabled: vm.isValid) {
                    if vm.createBudget(in: context) != nil {
                        HapticManager.success()
                        onCreated?()
                        dismiss()
                    }
                }
                .padding(AppMetrics.screenPadding)
                .background(.ultraThinMaterial)
            }
        }
    }

    private var dailyTargetCard: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(AppColor.info)
                Text("Vous avez \(vm.totalDays) jours")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
            }
            Text("Votre budget quotidien cible est de \(CurrencyFormatter.string(vm.dailyTarget, code: vm.currencyCode)).")
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                .fill(AppColor.infoSoft)
        )
    }

    @ViewBuilder
    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
            Text(title)
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                        .fill(AppColor.surface)
                )
        }
    }
}

#Preview {
    BudgetSetupView()
        .modelContainer(for: [Budget.self, Expense.self, Income.self], inMemory: true)
}
