import SwiftUI

@main
struct divclokApp: App {
  @StateObject private var statsVM = PieStatsViewModel()

  init() {
    let defaults = UserDefaults.standard
    if defaults.object(forKey: "startHour") == nil {
      defaults.set(22, forKey: "startHour")
      defaults.set(0, forKey: "startMinute")
      // Khởi tạo lastResetDate về một thời điểm trong quá khứ
      // để đảm bảo reset sẽ xảy ra khi cần thiết
      defaults.set(0, forKey: "lastResetDate")
    }
  }

  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(statsVM)
    }
  }
}
