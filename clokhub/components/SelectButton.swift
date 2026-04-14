import SwiftUI

struct SelectButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    Button(action: {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
        action()
      }
    }) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(isSelected ? .white : standardTextColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isSelected ? standardTextColor : Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
    .buttonStyle(.plain)
  }
}
