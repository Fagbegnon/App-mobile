import SwiftUI
import SwiftData

/// Ajout rapide d'une dépense (< 5 s). Clavier numérique intégré.
struct AddExpenseView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = AddExpenseViewModel()

    private var currency: String { budget.currencyCode }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppMetrics.spacingL) {
                        amountDisplay
                        categorySelector
                        detailsSection
                    }
                    .padding(AppMetrics.screenPadding)
                }

                AmountKeypad(
                    amount: $vm.amount,
                    fractionDigits: CurrencyFormatter.fractionDigits(for: currency)
                )
                .padding(.horizontal, AppMetrics.spacingS)
                .padding(.bottom, AppMetrics.spacingS)
            }
            .background(AppColor.background)
            .navigationTitle("Nouvelle dépense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { save() }
                        .fontWeight(.semibold)
                        .disabled(!vm.isValid)
                }
            }
        }
    }

    private var amountDisplay: some View {
        VStack(spacing: 4) {
            Text(CurrencyFormatter.string(vm.amount, code: currency, showSymbol: false))
                .font(AppFont.hero())
                .foregroundStyle(AppColor.positive)
                .contentTransition(.numericText(value: vm.amount))
                .animation(.snappy, value: vm.amount)
            Text(CurrencyFormatter.symbol(for: currency))
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppMetrics.spacingM)
    }

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
            Text("Catégorie")
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppMetrics.spacingM) {
                    ForEach(ExpenseCategory.allCases) { cat in
                        categoryChip(cat)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func categoryChip(_ cat: ExpenseCategory) -> some View {
        let selected = vm.category == cat
        return Button {
            HapticManager.selection()
            withAnimation(.snappy) { vm.category = cat; vm.subcategory = "" }
        } label: {
            VStack(spacing: 6) {
                CategoryIcon(systemImage: cat.systemImage, tint: cat.tint, size: 48)
                    .overlay {
                        if selected {
                            Circle().strokeBorder(cat.tint, lineWidth: 2).frame(width: 48, height: 48)
                        }
                    }
                Text(cat.label)
                    .font(AppFont.caption)
                    .foregroundStyle(selected ? AppColor.textPrimary : AppColor.textSecondary)
            }
            .frame(width: 64)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var detailsSection: some View {
        VStack(spacing: AppMetrics.spacingM) {
            if !vm.category.suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppMetrics.spacingS) {
                        ForEach(vm.category.suggestions, id: \.self) { s in
                            let on = vm.subcategory == s
                            Button {
                                HapticManager.selection()
                                vm.subcategory = on ? "" : s
                            } label: {
                                Text(s)
                                    .font(AppFont.footnote)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(on ? vm.category.tint.opacity(0.18) : AppColor.surface)
                                    )
                                    .foregroundStyle(on ? vm.category.tint : AppColor.textSecondary)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                }
            }

            VStack(spacing: 1) {
                labeledField("Description") {
                    TextField("Ex. Déjeuner au maquis", text: $vm.details)
                        .multilineTextAlignment(.trailing)
                }
                Divider()
                HStack {
                    Text("Paiement").foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    Picker("", selection: $vm.paymentMethod) {
                        ForEach(PaymentMethod.allCases) { m in
                            Label(m.label, systemImage: m.systemImage).tag(m)
                        }
                    }
                    .tint(AppColor.textPrimary)
                }
                .padding()
                Divider()
                HStack {
                    Text("Date").foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    DatePicker("", selection: $vm.date)
                        .labelsHidden()
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .fill(AppColor.surface)
            )
        }
    }

    @ViewBuilder
    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title).foregroundStyle(AppColor.textSecondary)
            Spacer()
            content()
        }
        .padding()
    }

    private func save() {
        guard vm.save(to: budget, in: context) else { return }
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Budget.self, Expense.self, Income.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let budget = Budget(initialAmount: 300000, startDate: .now, endDate: .now.addingTimeInterval(30*86400))
    container.mainContext.insert(budget)
    return AddExpenseView(budget: budget).modelContainer(container)
}
