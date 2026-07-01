import SwiftUI
import SwiftData

/// Barre d'onglets principale. L'onglet central « Ajouter » ouvre une feuille.
struct MainTabView: View {
    let budget: Budget

    @State private var selection: Tab = .home
    @State private var showAddExpense = false

    enum Tab: Hashable { case home, history, add, budget, profile }

    var body: some View {
        TabView(selection: tabSelection) {
            HomeView(budget: budget)
                .tabItem { Label("Accueil", systemImage: "house.fill") }
                .tag(Tab.home)

            HistoryView(budget: budget)
                .tabItem { Label("Dépenses", systemImage: "list.bullet.rectangle.fill") }
                .tag(Tab.history)

            // Onglet central : intercepté pour présenter la feuille d'ajout.
            Color.clear
                .tabItem { Label("Ajouter", systemImage: "plus.circle.fill") }
                .tag(Tab.add)

            BudgetDetailView(budget: budget)
                .tabItem { Label("Budget", systemImage: "chart.bar.xaxis") }
                .tag(Tab.budget)

            ProfileView(budget: budget)
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(Tab.profile)
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(budget: budget)
        }
    }

    /// Binding personnalisé : sélectionner « Ajouter » ouvre la feuille sans changer d'onglet.
    private var tabSelection: Binding<Tab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == .add {
                    HapticManager.impact(.medium)
                    showAddExpense = true
                } else {
                    selection = newValue
                }
            }
        )
    }
}
