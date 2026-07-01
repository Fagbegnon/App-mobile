# Budget Quotidien 💚

Application iPhone native (SwiftUI · iOS 18+) qui répond à **une seule question** :

> « Combien puis-je encore dépenser aujourd'hui ? »

Le budget quotidien conseillé est **recalculé chaque jour** :
`budget restant ÷ jours restants`. Trop dépenser un jour réduit le conseil
des jours suivants ; économiser l'augmente.

## Ouvrir le projet

> Xcode ne fonctionne que sur **macOS**. Copiez le dossier `BudgetQuotidien/`
> sur un Mac, puis :

```bash
open BudgetQuotidien.xcodeproj
```

1. Sélectionnez le schéma **BudgetQuotidien** et un simulateur iPhone (iOS 18+).
2. `⌘R` pour lancer · `⌘U` pour exécuter les tests.

Le projet utilise les **groupes synchronisés** d'Xcode 16
(`PBXFileSystemSynchronizedRootGroup`) : tout fichier `.swift` ajouté au dossier
`BudgetQuotidien/` est inclus automatiquement, sans manipulation du projet.

## Architecture (MVVM + SwiftData)

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour le détail. En résumé :

| Couche | Rôle |
|-------|------|
| `Models/` | `@Model` SwiftData : `Budget`, `Expense`, `Income` + enums |
| `Services/` | Logique métier — `BudgetCalculator` (pur, testé), `BudgetEngine`, notifications, haptique |
| `DesignSystem/` | Couleurs sémantiques, typo SF Pro, formatage FCFA |
| `Components/` | Jauge circulaire, barres, cartes, clavier numérique |
| `Features/` | Un dossier par écran (View + ViewModel) |
| `App/` | Point d'entrée, routing racine, TabBar |

## Écrans

Onboarding · Création du budget · **Accueil** (jauge + solde du jour) ·
Ajouter une dépense (clavier rapide, < 5 s) · Ajouter de l'argent ·
Historique (recherche + filtres jour/semaine/mois) · Budget (courbe d'évolution) ·
Statistiques (donut par catégorie) · Profil/Paramètres · Notifications ·
Résumé mensuel (taux de réussite, économies).

## Fonctionnalités clés

- 🔄 **Recalcul quotidien** du budget conseillé (cœur métier testé unitairement)
- 🔔 **Notifications locales** : dépassement, seuil 20 %, rappel 20h, résumé du soir
- 📳 **Retour haptique** sur chaque action
- 🌗 **Mode clair et sombre**
- 📊 **Swift Charts** (courbe d'évolution, répartition par catégorie)
- ✨ Animations douces façon Apple, jauge animée, transitions numériques

## Tests

`BudgetQuotidienTests/BudgetCalculatorTests.swift` (Swift Testing) couvre :
la durée de période, le budget initial/jour, le **recalcul quotidien**,
l'effet des dépassements et des revenus, l'isolation du « dépensé aujourd'hui »,
les seuils de statut et l'absence de division par zéro le dernier jour.

## Pistes d'évolution

- Verrouillage Face ID (`LocalAuthentication`) — l'UI est déjà présente
- Widgets & App Intents (« Ajouter une dépense » depuis l'écran d'accueil)
- Synchronisation iCloud (SwiftData + CloudKit)
- Export CSV / PDF du résumé mensuel
