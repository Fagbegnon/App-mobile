import SwiftUI
import SwiftData

/// Ajouter de l'argent au budget (salaire, prime, vente…).
struct AddIncomeView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double = 0
    @State private var type: IncomeType = .salary
    @State private var details: String = ""
    @State private var date: Date = .now

    private var currency: String { budget.currencyCode }
    private var isValid: Bool { amount > 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppMetrics.spacingL) {
                    amountDisplay

                    VStack(alignment: .leading, spacing: AppMetrics.spacingS) {
                        Text("Type").font(AppFont.footnote).foregroundStyle(AppColor.textSecondary)
                        ForEach(IncomeType.allCases) { t in typeRow(t) }
                            .card(padding: 4)
                    }

                    VStack(spacing: 1) {
                        HStack {
                            Text("Description").foregroundStyle(AppColor.textSecondary)
                            Spacer()
                            TextField("Salaire mensuel", text: $details)
                                .multilineTextAlignment(.trailing)
                        }.padding()
                        Divider()
                        HStack {
                            Text("Date").foregroundStyle(AppColor.textSecondary)
                            Spacer()
                            DatePicker("", selection: $date, displayedComponents: .date).labelsHidden()
                        }.padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                            .fill(AppColor.surface)
                    )
                }
                .padding(AppMetrics.screenPadding)
            }
            .background(AppColor.background)
            .navigationTitle("Ajouter de l'argent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { save() }.fontWeight(.semibold).disabled(!isValid)
                }
            }
        }
    }

    private var amountDisplay: some View {
        VStack(spacing: 8) {
            TextField("50 000", value: $amount, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(AppFont.hero())
                .foregroundStyle(AppColor.positive)
            Text(CurrencyFormatter.symbol(for: currency))
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.vertical, AppMetrics.spacingM)
    }

    private func typeRow(_ t: IncomeType) -> some View {
        let selected = type == t
        return Button {
            HapticManager.selection()
            withAnimation(.snappy) { type = t }
        } label: {
            HStack(spacing: AppMetrics.spacingM) {
                CategoryIcon(systemImage: t.systemImage, tint: t.tint, size: 36)
                Text(t.label).foregroundStyle(AppColor.textPrimary)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? AppColor.positive : AppColor.separator)
            }
            .padding(.vertical, 8).padding(.horizontal, 12)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func save() {
        guard isValid else { return }
        let income = Income(amount: amount, type: type,
                            details: details.isEmpty ? nil : details,
                            date: date, budget: budget)
        context.insert(income)
        try? context.save()
        HapticManager.success()
        dismiss()
    }
}
