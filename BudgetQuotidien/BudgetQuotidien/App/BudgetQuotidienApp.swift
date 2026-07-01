import SwiftUI
import SwiftData

@main
struct BudgetQuotidienApp: App {
    /// Conteneur SwiftData partagé.
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Budget.self, Expense.self, Income.self)
        } catch {
            fatalError("Impossible d'initialiser SwiftData : \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(AppColor.positive)
        }
        .modelContainer(container)
    }
}
