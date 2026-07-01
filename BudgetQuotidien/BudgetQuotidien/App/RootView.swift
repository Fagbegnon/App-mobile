import SwiftUI
import SwiftData

/// Aiguillage racine : Onboarding → Setup → application principale.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Budget> { $0.isActive }) private var activeBudgets: [Budget]

    @State private var settings = AppSettings.shared

    private var activeBudget: Budget? { activeBudgets.first }

    var body: some View {
        Group {
            if !settings.hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.smooth) { settings.hasCompletedOnboarding = true }
                }
                .transition(.opacity)
            } else if let budget = activeBudget {
                MainTabView(budget: budget)
                    .transition(.opacity)
            } else {
                BudgetSetupView(isFirstBudget: true)
                    .transition(.opacity)
            }
        }
        .animation(.smooth, value: settings.hasCompletedOnboarding)
        .animation(.smooth, value: activeBudget?.id)
        .task {
            if settings.notificationsEnabled {
                await NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.refreshSchedule(settings: settings)
            }
        }
    }
}
