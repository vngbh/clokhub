import SwiftUI

struct SettingsView: View {
    let pastelGreen = Color(red: 167/255, green: 233/255, blue: 211/255)
    @Environment(\.dismiss) var dismiss

    let standardTextColor = Color(red: 51/255, green: 51/255, blue: 51/255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsSection(title: "General", items: [
                        ("Enable Notifications", true),
                        ("Dark Mode", false),
                        ("Auto-Start Timer", true)
                    ], toggleColor: pastelGreen)

                    SettingsSection(title: "Sound & Haptics", items: [
                        ("Sound Effects", true),
                        ("Haptic Feedback", false)
                    ], toggleColor: pastelGreen)

                    SettingsSection(title: "Focus Modes", items: [
                        ("Pomodoro Mode", false),
                        ("Zen Mode", true)
                    ], toggleColor: pastelGreen)

                    SettingsSection(title: "Developer", items: [
                        ("Debug Mode", false)
                    ], toggleColor: pastelGreen)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // để tránh nút back bị che
            }

            // Nút back hình tròn cố định
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(standardTextColor))
            }

            .padding(.bottom, 10)
            .shadow(radius: 6)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

}

struct SettingsSection: View {
    let title: String
    let items: [(String, Bool)]
    let toggleColor: Color

    @State private var states: [Bool]

    init(title: String, items: [(String, Bool)], toggleColor: Color) {
        self.title = title
        self.items = items
        self.toggleColor = toggleColor
        _states = State(initialValue: items.map { $0.1 })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.black.opacity(0.8))
                .padding(.horizontal)

            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Text(items[index].0)
                        .foregroundColor(Color.black.opacity(0.8))
                    Spacer()
                    Toggle("", isOn: $states[index])
                        .labelsHidden()
                        .tint(toggleColor)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
