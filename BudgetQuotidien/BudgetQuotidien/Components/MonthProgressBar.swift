import SwiftUI

/// Barre de progression du budget mensuel.
struct MonthProgressBar: View {
    let fraction: Double        // 0…1
    var tint: Color = AppColor.positive
    @State private var animated: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(AppColor.separator)
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: geo.size.width * min(max(animated, 0), 1))
                    .animation(.smooth(duration: 0.8), value: animated)
            }
        }
        .frame(height: 10)
        .onAppear { animated = fraction }
        .onChange(of: fraction) { _, new in animated = new }
    }
}

#Preview {
    MonthProgressBar(fraction: 0.42).padding()
}
