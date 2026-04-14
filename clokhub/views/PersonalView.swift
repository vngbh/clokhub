import SwiftUI

struct PersonalView: View {
  @Environment(\.dismiss) var dismiss
  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        VStack(spacing: 24) {
          ProfileHeader(
            name: "vngbh",
            email: "vngbh@example.com",
            imageName: "Avatar",
            textColor: standardTextColor
          )
          .padding(.horizontal, 24)

          ProfileInfoSection(
            title: "Statistics",
            items: [
              "Total Focus Time: 14h 32m",
              "Average Daily: 2h 4m",
            ], textColor: standardTextColor)

          ProfileInfoSection(
            title: "Achievements",
            items: [
              "7‑Day Streak",
              "Early Bird",
            ], textColor: standardTextColor)
        }
        .padding(.top, 24)
        .padding(.bottom, 100)
      }

      CircleBackButton(action: { dismiss() })
        .padding(.bottom, 11)
    }
    .background(Color.white.ignoresSafeArea())
  }
}

#Preview {
  PersonalView()
}
