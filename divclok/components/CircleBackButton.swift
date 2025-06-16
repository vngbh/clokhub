import SwiftUI

struct CircleBackButton: View {
  let action: () -> Void
  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    Button(action: action) {
      Image(systemName: "chevron.left")
        .font(.system(size: 14, weight: .heavy))
        .foregroundColor(.white)
        .frame(width: 36, height: 36)
        .background(Circle().fill(standardTextColor))
        .shadow(radius: 6)
    }
  }
}

#Preview {
  CircleBackButton(action: {
    print("Back button tapped")
  })
  .padding()
}
