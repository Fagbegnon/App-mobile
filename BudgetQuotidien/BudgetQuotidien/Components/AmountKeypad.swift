import SwiftUI

/// Clavier numérique personnalisé pour saisir un montant rapidement (< 5 s).
struct AmountKeypad: View {
    @Binding var amount: Double
    /// Nombre de décimales autorisées (0 pour FCFA).
    var fractionDigits: Int = 0

    /// Chaîne interne de saisie (chiffres bruts).
    @State private var raw: String = ""

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        keyButton(key)
                    }
                }
            }
        }
        .onAppear { syncFromAmount() }
    }

    @ViewBuilder
    private func keyButton(_ key: String) -> some View {
        Button {
            tap(key)
        } label: {
            Group {
                if key == "⌫" {
                    Image(systemName: "delete.left")
                } else {
                    Text(key)
                }
            }
            .font(.system(size: 26, weight: .medium, design: .rounded))
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(key == "⌫" ? Color.clear : AppColor.surface)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(key == "." && fractionDigits == 0)
        .opacity(key == "." && fractionDigits == 0 ? 0.3 : 1)
    }

    private func tap(_ key: String) {
        HapticManager.selection()
        switch key {
        case "⌫":
            if !raw.isEmpty { raw.removeLast() }
        case ".":
            if fractionDigits > 0, !raw.contains(".") {
                raw += raw.isEmpty ? "0." : "."
            }
        default:
            // Limite les décimales.
            if let dot = raw.firstIndex(of: "."),
               raw.distance(from: dot, to: raw.endIndex) > fractionDigits {
                return
            }
            if raw == "0" { raw = key } else { raw += key }
        }
        amount = Double(raw) ?? 0
    }

    private func syncFromAmount() {
        guard amount > 0 else { raw = ""; return }
        raw = fractionDigits == 0 ? String(Int(amount)) : String(amount)
    }
}
