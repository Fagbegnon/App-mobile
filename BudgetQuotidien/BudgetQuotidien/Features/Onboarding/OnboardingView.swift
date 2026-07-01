import SwiftUI

/// Écran de démarrage. Présente l'application et lance la création du budget.
struct OnboardingView: View {
    /// Appelé quand l'utilisateur veut commencer.
    let onStart: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: AppMetrics.spacingL) {
                Spacer()

                illustration
                    .scaleEffect(appear ? 1 : 0.8)
                    .opacity(appear ? 1 : 0)

                VStack(spacing: AppMetrics.spacingM) {
                    Text("Maîtrisez votre budget")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColor.textPrimary)
                    + Text("\nau quotidien")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColor.positive)

                    Text("Suivez vos dépenses, respectez votre budget journalier et atteignez vos objectifs financiers.")
                        .font(AppFont.callout)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppMetrics.spacingL)
                }
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

                Spacer()

                VStack(spacing: AppMetrics.spacingS) {
                    PrimaryButton(title: "Commencer", systemImage: "arrow.right") {
                        onStart()
                    }
                    SecondaryButton(title: "J'ai déjà un compte") {
                        onStart()
                    }
                }
                .padding(.horizontal, AppMetrics.screenPadding)
                .opacity(appear ? 1 : 0)
            }
            .padding(.bottom, AppMetrics.spacingL)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { appear = true }
        }
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(AppColor.positiveSoft)
                .frame(width: 180, height: 180)
            Image(systemName: "wallet.bifold.fill")
                .font(.system(size: 78))
                .foregroundStyle(AppColor.positive.gradient)
                .symbolEffect(.bounce, value: appear)
        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
