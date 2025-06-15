import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) var dismiss

  private let standardTextColor = AppColors.standardTextColor
  private let pastelGreen = AppColors.pastelColors[1]

  @State private var startOfDay = Date()
  @State private var showHHMM = true
  @State private var defaultSessionLength: Double = 25
  @State private var selectedMode: String = "Divide"

  @State private var generalToggles = [
    ("Enable Notifications", true),
    ("Dark Mode", false),
    ("Auto‑Start Timer", true),
  ]

  @State private var soundToggles = [
    ("Sound Effects", true),
    ("Haptic Feedback", false),
  ]

  @State private var focusToggles = [
    ("Pomodoro Mode", false),
    ("Zen Mode", true),
  ]

  @State private var devToggles = [
    ("Debug Mode", false)
  ]

  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        VStack(spacing: 32) {
          timeSettings
          modeSettings

          SettingsSection(title: "General", items: $generalToggles, toggleColor: pastelGreen)
          SettingsSection(title: "Sound & Haptics", items: $soundToggles, toggleColor: pastelGreen)
          SettingsSection(title: "Focus Modes", items: $focusToggles, toggleColor: pastelGreen)
          SettingsSection(title: "Developer", items: $devToggles, toggleColor: pastelGreen)
        }
        .padding(.top, 24)
        .padding(.bottom, 100)
      }

      CircleBackButton(action: { dismiss() })
        .padding(.bottom, 10)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .onAppear {
      loadCurrentSettings()
    }
    .onChange(of: startOfDay) {
      let calendar = Calendar.current
      let comps = calendar.dateComponents([.hour, .minute], from: startOfDay)
      let hour = comps.hour ?? 0
      let minute = comps.minute ?? 0

      UserDefaults.standard.set(hour, forKey: "startHour")
      UserDefaults.standard.set(minute, forKey: "startMinute")
      // Notify ViewModels or reload stats if needed
      NotificationCenter.default.post(name: Notification.Name("ResetTimeChanged"), object: nil)
    }
  }

  private func loadCurrentSettings() {
    let defaults = UserDefaults.standard
    let hour = defaults.integer(forKey: "startHour")
    let minute = defaults.integer(forKey: "startMinute")

    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute

    if let date = calendar.date(from: dateComponents) {
      startOfDay = date
    }
  }

  private var timeSettings: some View {
    ControlSection(title: "Time Settings") {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Start of Day (reset)")
            .font(.subheadline)
            .foregroundColor(standardTextColor)

          DatePicker("", selection: $startOfDay, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Time Display Format")
            .font(.subheadline)
            .foregroundColor(standardTextColor)

          HStack(spacing: 12) {
            SelectButton(title: "HH:mm", isSelected: showHHMM) {
              showHHMM = true
            }
            SelectButton(title: "mm:ss", isSelected: !showHHMM) {
              showHHMM = false
            }
          }
          .padding(.horizontal, 48)
        }
      }
      .padding(.vertical, 8)
    }
  }

  private var modeSettings: some View {
    ControlSection(title: "Mode") {
      VStack(alignment: .leading, spacing: 16) {
        Text("Select Mode")
          .font(.subheadline)
          .foregroundColor(standardTextColor)

        HStack(spacing: 12) {
          SelectButton(title: "Divide", isSelected: selectedMode == "Divide") {
            selectedMode = "Divide"
          }
          SelectButton(title: "Pomodoro", isSelected: selectedMode == "Pomodoro") {
            selectedMode = "Pomodoro"
          }
        }
        .padding(.horizontal, 48)

        VStack(alignment: .leading, spacing: 12) {
          Text("Session Length")
            .font(.subheadline)
            .foregroundColor(standardTextColor)
            .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)

          HStack {
            Slider(value: $defaultSessionLength, in: 5...90, step: 5)
              .tint(pastelGreen)
              .disabled(selectedMode != "Pomodoro")
              .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)

            Text("\(Int(defaultSessionLength)) min")
              .monospacedDigit()
              .foregroundColor(standardTextColor)
              .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)
          }
          .padding(.horizontal, 48)
        }
      }
      .padding(.vertical, 8)
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }
  .environment(\.colorScheme, .light)  // 👈 nếu bạn muốn kiểm thử dark mode thì đổi sang .dark
}
