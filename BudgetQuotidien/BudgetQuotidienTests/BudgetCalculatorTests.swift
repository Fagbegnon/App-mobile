import Testing
import Foundation
@testable import BudgetQuotidien

/// Tests du cœur métier : la règle de recalcul quotidien.
struct BudgetCalculatorTests {

    // Calendrier déterministe (UTC) pour des tests stables.
    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    @Test("Durée d'un mois, bornes incluses")
    func totalDaysInclusive() {
        let days = BudgetCalculator.totalDays(start: date(2026, 7, 1), end: date(2026, 7, 31), calendar: calendar)
        #expect(days == 31)
    }

    @Test("Budget quotidien initial = total / nb jours")
    func initialDailyBudget() {
        let snap = BudgetCalculator.snapshot(
            initialAmount: 300_000,
            incomes: [],
            expenses: [],
            start: date(2026, 7, 1),
            end: date(2026, 7, 31),
            today: date(2026, 7, 1),
            calendar: calendar
        )
        #expect(Int(snap.initialDailyBudget) == 9677) // 300000 / 31
    }

    @Test("Le conseil du jour se recalcule sur le budget et les jours restants")
    func recommendedRecalculatesFromRemaining() {
        // 180 000 restants (300k - 120k dépensés), 18 jours restants => 10 000/jour.
        let snap = BudgetCalculator.snapshot(
            initialAmount: 300_000,
            incomes: [],
            expenses: [(120_000, date(2026, 7, 1))],
            start: date(2026, 7, 1),
            end: date(2026, 7, 31),
            today: date(2026, 7, 14), // 31 - 14 + 1 = 18 jours restants
            calendar: calendar
        )
        #expect(snap.remainingBudget == 180_000)
        #expect(snap.daysRemaining == 18)
        #expect(Int(snap.recommendedToday) == 10_000)
    }

    @Test("Trop dépenser fait baisser le conseil des jours suivants")
    func overspendingLowersFutureRecommendation() {
        let base = BudgetCalculator.snapshot(
            initialAmount: 310_000, incomes: [], expenses: [],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 1), calendar: calendar
        )
        let afterOverspend = BudgetCalculator.snapshot(
            initialAmount: 310_000, incomes: [],
            expenses: [(50_000, date(2026, 7, 1))],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 2), calendar: calendar
        )
        #expect(afterOverspend.recommendedToday < base.recommendedToday)
    }

    @Test("Ajouter de l'argent augmente le conseil du jour")
    func incomeRaisesRecommendation() {
        let without = BudgetCalculator.snapshot(
            initialAmount: 300_000, incomes: [], expenses: [],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 15), calendar: calendar
        )
        let with = BudgetCalculator.snapshot(
            initialAmount: 300_000, incomes: [(50_000, date(2026, 7, 15))], expenses: [],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 15), calendar: calendar
        )
        #expect(with.recommendedToday > without.recommendedToday)
    }

    @Test("Dépensé aujourd'hui ne compte que les dépenses du jour")
    func spentTodayIsolatesDay() {
        let snap = BudgetCalculator.snapshot(
            initialAmount: 300_000, incomes: [],
            expenses: [(2_500, date(2026, 7, 15)), (5_000, date(2026, 7, 14))],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 15), calendar: calendar
        )
        #expect(snap.spentToday == 2_500)
    }

    @Test("Statut du jour : sain, alerte (<20 %), dépassé")
    func dayStatusThresholds() {
        func status(spent: Double) -> BudgetStatus {
            BudgetCalculator.snapshot(
                initialAmount: 310_000, incomes: [],
                expenses: [(spent, date(2026, 7, 1))],
                start: date(2026, 7, 1), end: date(2026, 7, 31),
                today: date(2026, 7, 1), calendar: calendar
            ).dayStatus
        }
        // conseillé ≈ 10 000/jour au premier jour.
        #expect(status(spent: 1_000) == .healthy)
        #expect(status(spent: 9_000) == .warning) // reste 10% => < 20%
        #expect(status(spent: 12_000) == .over)
    }

    @Test("Jamais de division par zéro le dernier jour")
    func noDivisionByZeroOnLastDay() {
        let snap = BudgetCalculator.snapshot(
            initialAmount: 300_000, incomes: [], expenses: [],
            start: date(2026, 7, 1), end: date(2026, 7, 31),
            today: date(2026, 7, 31), calendar: calendar
        )
        #expect(snap.daysRemaining == 1)
        #expect(snap.recommendedToday == 300_000)
    }
}
