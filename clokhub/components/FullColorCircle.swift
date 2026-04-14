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

#Preview {
  VStack(spacing: 20) {
    FullColorCircle(color: .blue)
      .frame(width: 100, height: 100)

    FullColorCircle(color: .red)
      .frame(width: 150, height: 150)

    FullColorCircle(color: .green)
      .frame(width: 200, height: 200)
  }
  .padding()
}
