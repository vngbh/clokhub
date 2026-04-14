import SwiftUI

struct SettingsSection: View {
  let title: String
  @Binding var items: [(String, Bool)]
  let toggleColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .foregroundColor(.black.opacity(0.8))
        .padding(.horizontal)
      ForEach(items.indices, id: \.self) { i in
        HStack {
          Text(items[i].0).foregroundColor(.black.opacity(0.8))
          Spacer()
          Toggle("", isOn: $items[i].1)
            .labelsHidden()
            .tint(toggleColor)
        }
        .padding(.horizontal)
      }
    }
    .padding(.vertical, 12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
    .padding(.horizontal, 24)
  }
}
