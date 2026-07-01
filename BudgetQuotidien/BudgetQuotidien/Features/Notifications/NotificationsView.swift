import SwiftUI

/// Journal des notifications (feed informatif).
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    struct Item: Identifiable {
        let id = UUID()
        let time: String
        let icon: String
        let tint: Color
        let text: String
    }

    // Feed de démonstration reflétant les types de notifications réels de l'app.
    private let today: [Item] = [
        .init(time: "20:00", icon: "target", tint: AppColor.info,
              text: "Il vous reste de la marge pour respecter votre budget quotidien."),
        .init(time: "12:46", icon: "arrow.down.circle.fill", tint: AppColor.danger,
              text: "Dépense ajoutée : déjeuner au maquis."),
        .init(time: "09:00", icon: "sun.max.fill", tint: AppColor.warning,
              text: "Bonne journée ! N'oubliez pas de suivre vos dépenses.")
    ]
    private let yesterday: [Item] = [
        .init(time: "21:00", icon: "checkmark.seal.fill", tint: AppColor.positive,
              text: "Félicitations 🎉 Vous avez respecté votre budget hier."),
        .init(time: "18:30", icon: "chart.bar.fill", tint: AppColor.info,
              text: "Vous avez dépensé 80 % de votre budget quotidien.")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Aujourd'hui") { ForEach(today) { row($0) } }
                Section("Hier") { ForEach(yesterday) { row($0) } }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Fermer") { dismiss() } }
            }
        }
    }

    private func row(_ item: Item) -> some View {
        HStack(alignment: .top, spacing: AppMetrics.spacingM) {
            CategoryIcon(systemImage: item.icon, tint: item.tint, size: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text).font(AppFont.subheadline).foregroundStyle(AppColor.textPrimary)
                Text(item.time).font(AppFont.caption).foregroundStyle(AppColor.textSecondary)
            }
        }
        .listRowBackground(AppColor.surface)
        .padding(.vertical, 4)
    }
}
