import SwiftUI

struct CircleBackButton: View {
  let action: () -> Void
  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    Button(action: action) {
      Image(systemName: "xmark")
        .font(.system(size: 18, weight: .bold))
        .foregroundColor(standardTextColor)
        .frame(width: 60, height: 60)
        .background(.ultraThinMaterial, in: Circle())
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    CircleBackButton(action: {
      print("Close button tapped")
    })

    ZStack {
      Color.blue.opacity(0.3)
        .frame(width: 200, height: 100)

      CircleBackButton(action: {
        print("Close button tapped")
      })
    }
    .cornerRadius(12)
  }
  .padding()
}
