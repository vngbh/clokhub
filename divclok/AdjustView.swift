import SwiftUI

struct AdjustView: View {
    @Environment(\.dismiss) var dismiss
    let standardTextColor = Color(red: 51/255, green: 51/255, blue: 51/255)
    let pastelGreen = Color(red: 167/255, green: 233/255, blue: 211/255)

    @State private var startOfDay = Date()
    @State private var showHHMM = true
    @State private var defaultSessionLength: Double = 25
    @State private var selectedMode: String = "Divide"

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 32) {
                    // Time Settings
                    SettingControlSection(title: "Time Settings") {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start of Day (reset)")
                                    .font(.subheadline)
                                    .foregroundColor(standardTextColor)
                                    .padding(.bottom, 6)
                                DatePicker("", selection: $startOfDay, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .cornerRadius(6)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Time Display Format")
                                    .font(.subheadline)
                                    .foregroundColor(standardTextColor)
                                    .padding(.bottom, 6)
                                HStack(spacing: 12) {
                                    ToggleButton(title: "HH:mm", isSelected: showHHMM) {
                                        showHHMM = true
                                    }
                                    ToggleButton(title: "mm:ss", isSelected: !showHHMM) {
                                        showHHMM = false
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 48)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }

                    // Mode + Session Length
                    SettingControlSection(title: "Mode") {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Mode")
                                .font(.subheadline)
                                .foregroundColor(standardTextColor)

                            HStack(spacing: 12) {
                                ToggleButton(title: "Divide", isSelected: selectedMode == "Divide") {
                                    selectedMode = "Divide"
                                }
                                ToggleButton(title: "Pomodoro", isSelected: selectedMode == "Pomodoro") {
                                    selectedMode = "Pomodoro"
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 48)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Session Length")
                                    .font(.subheadline)
                                    .foregroundColor(standardTextColor)
                                    .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)

                                HStack {
                                    Spacer()
                                    HStack(spacing: 12) {
                                        Slider(value: $defaultSessionLength, in: 5...90, step: 5)
                                            .tint(pastelGreen)
                                            .disabled(selectedMode != "Pomodoro")
                                            .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)

                                        HStack(spacing: 0) {
                                            Text(String(format: "%3d", Int(defaultSessionLength)))
                                                .monospacedDigit()
                                                .frame(width: 36, alignment: .trailing) // cố định số
                                            Text(" min")
                                        }
                                        .foregroundColor(standardTextColor)
                                        .opacity(selectedMode == "Pomodoro" ? 1.0 : 0.5)
                                        .frame(width: 90, alignment: .leading) // toàn bộ khối "số + minutes"
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75)
                                    Spacer()
                                }

                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }

                    // Support tab
                    VStack(alignment: .center, spacing: 8) {
                        Text("Enjoying the app?")
                            .font(.headline)
                            .foregroundColor(standardTextColor)

                        Text("Support the creator on Patreon!")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(standardTextColor)
                            .padding(.bottom, 6)

                        HStack {
                            Spacer()
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Buy Me a Coffee")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(standardTextColor)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 72)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    .background(pastelGreen)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }

            // Back button
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

// Section wrapper
struct SettingControlSection<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                .padding(.horizontal)

            content()
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

// Toggle-style button
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let standardTextColor = Color(red: 51/255, green: 51/255, blue: 51/255)

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

// Preview
#Preview {
    NavigationStack {
        AdjustView()
    }
}
