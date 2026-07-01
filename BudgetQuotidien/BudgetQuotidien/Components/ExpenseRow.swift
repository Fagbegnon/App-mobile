import SwiftUI

/// Ligne d'une dépense dans l'historique.
struct ExpenseRow: View {
    let expense: Expense
    let currency: String

    var body: some View {
        HStack(spacing: AppMetrics.spacingM) {
            CategoryIcon(systemImage: expense.category.systemImage, tint: expense.category.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.details?.isEmpty == false ? expense.details! : expense.category.label)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("-\(CurrencyFormatter.string(expense.amount, code: currency))")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(expense.date, format: .dateTime.hour().minute())
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var subtitle: String {
        var parts = [expense.category.label]
        if let sub = expense.subcategory, !sub.isEmpty { parts.append(sub) }
        return parts.joined(separator: " • ")
    }
}
