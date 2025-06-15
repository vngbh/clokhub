import SwiftUI

struct PersonalView: View {
    @Environment(\.dismiss) var dismiss
    let standardTextColor = Color(red: 51/255, green: 51/255, blue: 51/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Tab with Avatar
                    VStack(alignment: .center, spacing: 16) {
                        Image("Avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                        Text("vngbh")
                            .font(.title2.bold())
                            .foregroundColor(standardTextColor)
                        Text("vngbh@example.com")
                            .font(.subheadline)
                            .foregroundColor(standardTextColor)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    // Statistics Tab
                    ProfileInfoSection(title: "Statistics", items: [
                        "Total Focus Time: 14h 32m",
                        "Average Daily: 2h 4m"
                    ], textColor: standardTextColor)

                    // Achievements Tab
                    ProfileInfoSection(title: "Achievements", items: [
                        "7‑Day Streak",
                        "Early Bird"
                    ], textColor: standardTextColor)
                }
                .padding(.top, 24)
                .padding(.bottom, 100) // tránh che nút back
            }

            // Nút back hình tròn cố định
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(standardTextColor))
                    .shadow(radius: 6)
            }
            .padding(.bottom, 11)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

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
    NavigationStack {
        PersonalView()
    }
}
