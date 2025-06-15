import SwiftUI

struct ProfileInfoSection: View {
  let title: String
  let items: [String]
  let textColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .foregroundColor(textColor)
        .padding(.horizontal)

      ForEach(items, id: \.self) { line in
        HStack {
          Text(line)
            .foregroundColor(textColor)
          Spacer()
        }
        .padding(.horizontal)
      }
    }
    .padding(.vertical)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
    .padding(.horizontal, 24)
  }
}

#Preview {
  ProfileInfoSection(
    title: "Achievements",
    items: ["7-Day Streak", "Early Bird"],
    textColor: AppColors.standardTextColor
  )
}
