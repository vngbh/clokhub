import Foundation

final class PieStatsViewModel: ObservableObject {
  @Published var dailyStats: [String: [Double]]
  @Published var currentDayLive: [Double] = [0, 0, 0]

  // Cache chỉ dùng cho ngày hiện tại
  private var cachedTodayKey: String = ""
  private var lastKeyUpdate: Date = Date.distantPast
  private var lastLiveUpdate: Date = Date.distantPast

  private var jstCalendar: Calendar {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
    return calendar
  }

  let repo = PieStatsRepository()

  init() {
    self.dailyStats = repo.fetchAll()
    let todayKey = getLogicalKey(for: Date())
    if let todayStat = dailyStats[todayKey] {
      self.currentDayLive = todayStat
    }
  }

  func getLogicalKey(for date: Date = Date()) -> String {
    // Chỉ cache cho date hiện tại
    let now = Date()
    if date.timeIntervalSince(now) > -1 && date.timeIntervalSince(now) < 1 {
      if Date().timeIntervalSince(lastKeyUpdate) < 60 && !cachedTodayKey.isEmpty {
        return cachedTodayKey
      }
    }

    let startHour = UserDefaults.standard.integer(forKey: "startHour")
    let startMinute = UserDefaults.standard.integer(forKey: "startMinute")

    // Lấy giờ:phút theo JST
    let currentHour = jstCalendar.component(.hour, from: date)
    let currentMinute = jstCalendar.component(.minute, from: date)

    let currentTotalMinutes = currentHour * 60 + currentMinute
    let resetTotalMinutes = startHour * 60 + startMinute

    // Chuyển date thành JST date trước khi -1 ngày để đảm bảo đúng ngày trong timezone JST
    let jstDate = date.addingTimeInterval(
      TimeInterval(TimeZone(identifier: "Asia/Tokyo")?.secondsFromGMT() ?? 0))

    let logicDate: Date
    if currentTotalMinutes < resetTotalMinutes {
      // Chưa đến giờ reset → lấy ngày hôm qua (trong JST)
      logicDate = jstCalendar.date(byAdding: .day, value: -1, to: jstDate)!
    } else {
      // Đã qua giờ reset → ngày hiện tại (trong JST)
      logicDate = jstDate
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = jstCalendar
    formatter.timeZone = jstCalendar.timeZone
    let key = formatter.string(from: logicDate)

    if date.timeIntervalSince(now) > -1 && date.timeIntervalSince(now) < 1 {
      cachedTodayKey = key
      lastKeyUpdate = now
    }

    return key
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

    if total == 0 {
      return
    }

    // Convert thành phần trăm để lưu vào Core Data cho pie chart
    let percents = currentDayLive.map { total > 0 ? $0 / total : 0 }
    repo.saveOrUpdate(date: key, values: percents)
    refreshStats()
  }

  func refreshStats() {
    let oldCount = dailyStats.count
    dailyStats = repo.fetchAll()
    let newCount = dailyStats.count

    if oldCount != newCount {
      print("📊 Stats refreshed: \(oldCount) -> \(newCount) entries")
    }

    // Không cập nhật currentDayLive từ Core Data vì nó lưu phần trăm
    // currentDayLive sẽ được cập nhật trực tiếp từ ContentView
  }

  func resetCurrentDay() {
    currentDayLive = [0, 0, 0]
    // Reset cache khi có reset
    cachedTodayKey = ""
    lastKeyUpdate = Date.distantPast
    lastLiveUpdate = Date.distantPast
  }

  func invalidateLogicalKeyCache() {
    cachedTodayKey = ""
    lastKeyUpdate = Date.distantPast
  }

  func updateCurrentDayLive(
    with times: [Int: TimeInterval], selectedIndex: Int, currentStartTime: Date,
    forceUpdate: Bool = false
  ) {
    // Throttle update để tránh tính toán quá thường xuyên cho UI
    // Cho phép update ngay lập tức khi selectedIndex thay đổi
    let now = Date()
    let shouldUpdate = forceUpdate || now.timeIntervalSince(lastLiveUpdate) >= 0.1  // 10 FPS cho live data

    if shouldUpdate {
      currentDayLive = (0..<3).map { i in
        let segmentTime =
          times[i, default: 0]
          + (selectedIndex == i ? now.timeIntervalSince(currentStartTime) : 0)
        return segmentTime
      }
      lastLiveUpdate = now
    }
  }
}
