import SwiftUI

struct ProfileHeader: View {
  let name: String
  let email: String
  let imageName: String
  let textColor: Color

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      Image(imageName)
        .resizable()
        .scaledToFill()
        .frame(width: 96, height: 96)
        .clipShape(Circle())
        .shadow(radius: 4)

      Text(name)
        .font(.title2.bold())
        .foregroundColor(textColor)

      Text(email)
        .font(.subheadline)
        .foregroundColor(textColor)
    }
    .padding(.vertical)
    .frame(maxWidth: .infinity)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
  }
}
