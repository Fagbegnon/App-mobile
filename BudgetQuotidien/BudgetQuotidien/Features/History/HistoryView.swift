import SwiftUI
import SwiftData

/// Historique des dépenses : recherche, filtres jour/semaine/mois, groupé par date.
struct HistoryView: View {
    let budget: Budget

    @Environment(\.modelContext) private var context
    @State private var search = ""
    @State private var range: TimeRange = .day

    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "Jour", week = "Semaine", month = "Mois"
        var id: String { rawValue }
    }

    private var currency: String { budget.currencyCode }

    private var filtered: [Expense] {
        let cal = Calendar.current
        let now = Date.now
        return budget.expenses.filter { e in
            let inRange: Bool
            switch range {
            case .day: inRange = cal.isDate(e.date, inSameDayAs: now)
            case .week: inRange = cal.isDate(e.date, equalTo: now, toGranularity: .weekOfYear)
            case .month: inRange = cal.isDate(e.date, equalTo: now, toGranularity: .month)
            }
            let matchesSearch = search.isEmpty
                || (e.details ?? "").localizedCaseInsensitiveContains(search)
                || e.category.label.localizedCaseInsensitiveContains(search)
                || (e.subcategory ?? "").localizedCaseInsensitiveContains(search)
            return inRange && matchesSearch
        }
    }

    private var grouped: [(day: Date, items: [Expense])] {
        BudgetEngine.groupedByDay(filtered)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(grouped, id: \.day) { group in
                            Section {
                                ForEach(group.items) { expense in
                                    ExpenseRow(expense: expense, currency: currency)
                                        .listRowBackground(AppColor.surface)
                                }
                                .onDelete { indexSet in delete(indexSet, in: group.items) }
                            } header: {
                                dayHeader(group.day, total: group.items.reduce(0) { $0 + $1.amount })
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColor.background)
            .navigationTitle("Dépenses")
            .searchable(text: $search, prompt: "Rechercher")
            .safeAreaInset(edge: .top) { filterBar }
        }
    }

    private var filterBar: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppMetrics.screenPadding)
        .padding(.vertical, AppMetrics.spacingS)
        .background(AppColor.background)
    }

    private func dayHeader(_ day: Date, total: Double) -> some View {
        HStack {
            Text(day, format: .dateTime.weekday(.wide).day().month())
                .textCase(nil)
            Spacer()
            Text("Total: \(CurrencyFormatter.string(total, code: currency))")
                .foregroundStyle(AppColor.textSecondary)
        }
        .font(AppFont.footnote)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Aucune dépense", systemImage: "tray")
        } description: {
            Text("Vos dépenses apparaîtront ici.")
        }
    }

    private func delete(_ offsets: IndexSet, in items: [Expense]) {
        for i in offsets {
            let expense = items[i]
            context.delete(expense)
        }
        try? context.save()
        HapticManager.impact(.light)
    }
}
