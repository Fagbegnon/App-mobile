import SwiftUI

/// Pastille ronde avec l'icône d'une catégorie.
struct CategoryIcon: View {
    let systemImage: String
    let tint: Color
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                Circle().fill(tint.opacity(0.15))
            )
    }
}

#Preview {
    HStack {
        ForEach(ExpenseCategory.allCases) { c in
            CategoryIcon(systemImage: c.systemImage, tint: c.tint)
        }
    }.padding()
}
