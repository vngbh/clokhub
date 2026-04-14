import SwiftUI

@main
struct clokhubApp: App {
  @StateObject private var statsVM: PieStatsViewModel

  init() {
    // Configure defaults before creating PieStatsViewModel.
    let defaults = UserDefaults.standard
    if defaults.object(forKey: "startHour") == nil {
      defaults.set(22, forKey: "startHour")
      defaults.set(0, forKey: "startMinute")
      // Start far in the past so the next reset can run when needed.
      defaults.set(0, forKey: "lastResetDate")
    }

    self._statsVM = StateObject(wrappedValue: PieStatsViewModel())
  }

  private static func clearAllData() {
    print("DEBUG: Clearing all app data...")

    let defaults = UserDefaults.standard
    let keys = [
      "startHour", "startMinute", "lastResetDate",
      "accumulatedTimes", "selectedIndex", "lastSavedTime",
    ]

    for key in keys {
      defaults.removeObject(forKey: key)
    }

    let repo = PieStatsRepository()
    repo.deleteAll()

    print("DEBUG: All app data cleared!")
  }

  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(statsVM)
    }
  }
}
