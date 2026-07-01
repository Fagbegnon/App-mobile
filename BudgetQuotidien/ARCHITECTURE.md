# Budget Quotidien — Architecture

Application iOS native (SwiftUI, iOS 18+) qui répond à une seule question :
**« Combien puis-je encore dépenser aujourd'hui ? »**

## Stack technique
- **SwiftUI** uniquement (iOS 18+)
- **SwiftData** pour la persistance locale
- **Architecture MVVM** (Model · ViewModel · View)
- **Swift Charts** pour les graphiques
- **UserNotifications** pour les notifications locales
- **CoreHaptics / UIFeedbackGenerator** pour le retour haptique

## Arborescence

```
BudgetQuotidien/
├── App/
│   ├── BudgetQuotidienApp.swift      # @main, ModelContainer, routing racine
│   └── RootView.swift                # Décide Onboarding / Setup / TabBar
├── Models/                           # @Model SwiftData + enums métier
│   ├── Budget.swift
│   ├── Expense.swift
│   ├── Income.swift
│   ├── ExpenseCategory.swift
│   ├── IncomeType.swift
│   └── PaymentMethod.swift
├── Services/                         # Logique métier pure & effets
│   ├── BudgetCalculator.swift        # Cœur du calcul (testable, pur)
│   ├── BudgetEngine.swift            # Orchestration SwiftData ↔ calcul
│   ├── NotificationManager.swift     # Notifications locales
│   ├── HapticManager.swift           # Retour haptique
│   └── AppSettings.swift             # Préférences (@AppStorage)
├── DesignSystem/
│   ├── AppColor.swift                # Palette sémantique (clair/sombre)
│   ├── AppFont.swift                 # Typographie SF Pro
│   ├── AppMetrics.swift              # Rayons, espacements, ombres
│   └── CurrencyFormatter.swift       # Formatage FCFA / devises
├── Components/                       # Vues réutilisables
│   ├── CircularBudgetGauge.swift
│   ├── MonthProgressBar.swift
│   ├── StatCard.swift
│   ├── PrimaryButton.swift
│   ├── CategoryIcon.swift
│   ├── AmountKeypad.swift
│   └── CardBackground.swift
├── Features/                         # Un dossier par écran (View + ViewModel)
│   ├── Onboarding/OnboardingView.swift
│   ├── Setup/BudgetSetupView.swift + BudgetSetupViewModel.swift
│   ├── Home/HomeView.swift + HomeViewModel.swift
│   ├── AddExpense/AddExpenseView.swift + AddExpenseViewModel.swift
│   ├── AddIncome/AddIncomeView.swift + AddIncomeViewModel.swift
│   ├── History/HistoryView.swift + HistoryViewModel.swift
│   ├── BudgetDetail/BudgetDetailView.swift + BudgetDetailViewModel.swift
│   ├── Statistics/StatisticsView.swift
│   ├── Profile/ProfileView.swift
│   └── Summary/MonthlySummaryView.swift
└── Resources/
    └── Assets (couleurs, AppIcon) — à ajouter dans Xcode
```

## Cœur métier — recalcul quotidien

Le budget conseillé n'est **pas** figé. Il est recalculé à chaque ouverture :

```
budgetTotal      = budgetInitial + Σ revenus
totalDépensé     = Σ dépenses
budgetRestant    = budgetTotal − totalDépensé
joursRestants    = jours entre aujourd'hui et dateFin (inclus)
conseilléAujourd = budgetRestant / joursRestants
dépenséAujourd   = Σ dépenses(aujourd'hui)
soldeAujourd     = conseilléAujourd − dépenséAujourd
```

Ainsi : trop dépenser un jour ⇒ conseil des jours suivants baisse.
Économiser ⇒ conseil augmente.

Toute cette logique vit dans `BudgetCalculator` (fonctions pures, 100 % testables)
et est exposée à l'UI via `BudgetEngine` + `HomeViewModel`.

## Flux de navigation
1. **Onboarding** (premier lancement)
2. **Setup** (aucun budget actif)
3. **TabBar** : Accueil · Historique · **Ajouter** · Budget · Profil

## Palette sémantique
| Couleur | Sens |
|--------|------|
| Vert   | Budget disponible / OK |
| Orange | Attention (< 20 % du jour) |
| Rouge  | Dépassement |
| Bleu   | Informations |
| Gris très clair | Fond |
```
```
