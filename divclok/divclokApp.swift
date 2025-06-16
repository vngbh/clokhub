import SwiftUI

@main
struct divclokApp: App {
  @StateObject private var statsVM: PieStatsViewModel

  init() {
    // DEBUG: Xóa sạch data để debug dễ dàng hơn
    // #if DEBUG
    //   Self.clearAllData()
    // #endif

    // Thiết lập UserDefaults TRƯỚC KHI khởi tạo PieStatsViewModel
    let defaults = UserDefaults.standard
    if defaults.object(forKey: "startHour") == nil {
      defaults.set(22, forKey: "startHour")
      defaults.set(0, forKey: "startMinute")
      // Khởi tạo lastResetDate về một thời điểm trong quá khứ
      // để đảm bảo reset sẽ xảy ra khi cần thiết
      defaults.set(0, forKey: "lastResetDate")
    }

    // Bây giờ mới khởi tạo statsVM
    self._statsVM = StateObject(wrappedValue: PieStatsViewModel())
  }

  private static func clearAllData() {
    print("🧹 DEBUG: Clearing all app data...")

    // Xóa UserDefaults
    let defaults = UserDefaults.standard
    let keys = [
      "startHour", "startMinute", "lastResetDate",
      "accumulatedTimes", "selectedIndex", "lastSavedTime",
    ]

    for key in keys {
      defaults.removeObject(forKey: key)
    }

    // Xóa Core Data
    let repo = PieStatsRepository()
    repo.deleteAll()

    print("✅ DEBUG: All app data cleared!")
  }

  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(statsVM)
    }
  }
}
