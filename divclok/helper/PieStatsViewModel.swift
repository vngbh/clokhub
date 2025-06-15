import Foundation

final class PieStatsViewModel: ObservableObject {
  @Published var dailyStats: [String: [Double]]
  @Published var currentDayLive: [Double] = [0, 0, 0]

  let repo = PieStatsRepository()

  init() {
    self.dailyStats = repo.fetchAll()
    let todayKey = getLogicalKey(for: Date())
    if let todayStat = dailyStats[todayKey] {
      self.currentDayLive = todayStat
    }
  }

  func getLogicalKey(for date: Date = Date()) -> String {
    let calendar = Calendar.current
    let startHour = UserDefaults.standard.integer(forKey: "startHour")
    let startMinute = UserDefaults.standard.integer(forKey: "startMinute")
    let resetTime = calendar.date(
      bySettingHour: startHour, minute: startMinute, second: 0, of: date)!
    let logicDate: Date
    if date < resetTime {
      logicDate = calendar.date(byAdding: .day, value: -1, to: date)!
    } else {
      logicDate = date
    }
    return DateFormatter.yyyyMMdd.string(from: logicDate)
  }

  func stats(for date: Date) -> [Double]? {
    let key = getLogicalKey(for: date)
    let todayKey = getLogicalKey(for: Date())
    if key == todayKey {
      // Cho ngày hôm nay, convert thời gian thực tế thành phần trăm
      let total = currentDayLive.reduce(0, +)
      return currentDayLive.map { total > 0 ? $0 / total : 0 }
    } else {
      // Cho các ngày khác, trả về phần trăm đã lưu trong Core Data
      return dailyStats[key]
    }
  }

  func recordCurrentDayStat(for date: Date = Date()) {
    let key = getLogicalKey(for: date)
    // Tính tổng thời gian
    let total = currentDayLive.reduce(0, +)
    // Convert thành phần trăm để lưu vào Core Data cho pie chart
    let percents = currentDayLive.map { total > 0 ? $0 / total : 0 }
    repo.saveOrUpdate(date: key, values: percents)
    refreshStats()
  }

  func refreshStats() {
    dailyStats = repo.fetchAll()
    // Không cập nhật currentDayLive từ Core Data vì nó lưu phần trăm
    // currentDayLive sẽ được cập nhật trực tiếp từ ContentView
  }

  func resetCurrentDay() {
    currentDayLive = [0, 0, 0]
  }

  func updateCurrentDayLive(
    with times: [Int: TimeInterval], selectedIndex: Int, currentStartTime: Date
  ) {
    let currentTime = Date()

    currentDayLive = (0..<3).map { i in
      let segmentTime =
        times[i, default: 0]
        + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
      return segmentTime
    }
  }
}
