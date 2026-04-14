import SwiftUI

struct ControlSection<Content: View>: View {
  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .foregroundColor(.black.opacity(0.8))
        .padding(.horizontal)
      content
        .padding(.horizontal)
    }
    .padding(.vertical, 12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
    .padding(.horizontal, 24)
  }
}
