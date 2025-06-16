import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) var dismiss

  private let standardTextColor = AppColors.standardTextColor
  private let pastelGreen = AppColors.pastelColors[1]

  @State private var startOfDay = Date()
  @State private var tempStartOfDay = Date()  // Temporary storage for pending changes
  @State private var showHHMM = true
  @State private var defaultSessionLength: Double = 25
  @State private var selectedMode: String = "Divide"
  @State private var currentHour = 0
  @State private var currentMinute = 0
  @State private var showTimePicker = false
  @State private var isEditingTime = false  // Track if user is currently editing time

  @State private var lastNotificationTime = Date.distantPast

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
    .onChange(of: startOfDay) { oldValue, newValue in
      // Ignore changes when we're editing or when changes are being applied through applyTimeChange
      if !isEditingTime {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: newValue)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0

        // Just update the display values, actual changes are handled by applyTimeChange
        if hour != currentHour || minute != currentMinute {
          currentHour = hour
          currentMinute = minute
        }
      }
    }
  }

  private func loadCurrentSettings() {
    let defaults = UserDefaults.standard
    currentHour = defaults.integer(forKey: "startHour")
    currentMinute = defaults.integer(forKey: "startMinute")

    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.hour = currentHour
    dateComponents.minute = currentMinute

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

          Button(action: {
            tempStartOfDay = startOfDay
            isEditingTime = true
            showTimePicker = true
          }) {
            HStack {
              Text(timeString(from: startOfDay))
                .font(.system(size: 16))
                .foregroundColor(standardTextColor)
              Image(systemName: "clock")
                .foregroundColor(standardTextColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
          }
          .sheet(
            isPresented: $showTimePicker,
            onDismiss: {
              isEditingTime = false
            }
          ) {
            NavigationView {
              DatePicker("", selection: $tempStartOfDay, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .navigationBarItems(
                  leading: Button("Cancel") {
                    isEditingTime = false
                    showTimePicker = false
                  },
                  trailing: Button("Done") {
                    startOfDay = tempStartOfDay
                    isEditingTime = false
                    showTimePicker = false
                    applyTimeChange(tempStartOfDay)
                  }
                )
            }
            .presentationDetents([.height(280)])
          }
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

  private func timeString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }

  private func applyTimeChange(_ date: Date) {
    let calendar = Calendar.current
    let comps = calendar.dateComponents([.hour, .minute], from: date)
    let hour = comps.hour ?? 0
    let minute = comps.minute ?? 0

    if hour != currentHour || minute != currentMinute {
      currentHour = hour
      currentMinute = minute
      UserDefaults.standard.set(hour, forKey: "startHour")
      UserDefaults.standard.set(minute, forKey: "startMinute")
      NotificationCenter.default.post(name: Notification.Name("ResetTimeChanged"), object: nil)
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
