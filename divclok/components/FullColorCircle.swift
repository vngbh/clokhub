import SwiftUI

struct FullColorCircle: View {
    let color: Color

    var body: some View {
        Circle()
            .stroke(
                color.opacity(0.9),
                style: StrokeStyle(lineWidth: 24, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .shadow(color: .black.opacity(0.24), radius: 6)
    }
}
