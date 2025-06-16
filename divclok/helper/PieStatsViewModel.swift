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
    let resetTotalMinutes = startHour * 60 + startMinute

    // Sử dụng JST timezone trực tiếp
    let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
    var jstCalendarCopy = Calendar.current
    jstCalendarCopy.timeZone = jstTimeZone

    // Lấy thời gian hiện tại theo JST
    let currentHour = jstCalendarCopy.component(.hour, from: date)
    let currentMinute = jstCalendarCopy.component(.minute, from: date)
    let currentTotalMinutes = currentHour * 60 + currentMinute

    // Calculate logical date in JST
    let logicDate: Date
    if currentTotalMinutes >= resetTotalMinutes {
      // Đã qua giờ reset của ngày mới → dùng ngày hiện tại
      logicDate = date

    } else {
      // Chưa tới giờ reset của ngày mới → vẫn tính là ngày hôm trước
      logicDate = jstCalendarCopy.date(byAdding: .day, value: -1, to: date)!

    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = jstTimeZone
    let key = formatter.string(from: logicDate)

    // Only cache if this is the current date
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

    // Immediately update dailyStats for UI
    dailyStats[key] = percents

    // Trigger UI update
    DispatchQueue.main.async {
      self.objectWillChange.send()
    }

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
    // Lưu dữ liệu của ngày logic cũ trước khi invalidate cache
    let oldLogicalKey = cachedTodayKey

    cachedTodayKey = ""
    lastKeyUpdate = Date.distantPast

    // Kiểm tra xem ngày logic có thay đổi không
    let newLogicalKey = getLogicalKey(for: Date())

    if !oldLogicalKey.isEmpty && oldLogicalKey != newLogicalKey {
      // Ngày logic đã thay đổi, lưu dữ liệu của ngày cũ
      let total = currentDayLive.reduce(0, +)
      if total > 0 {
        let percents = currentDayLive.map { total > 0 ? $0 / total : 0 }
        repo.saveOrUpdate(date: oldLogicalKey, values: percents)

        // Cập nhật dailyStats ngay lập tức để hiển thị trong calendar
        dailyStats[oldLogicalKey] = percents

        // Reset currentDayLive cho ngày mới
        currentDayLive = [0, 0, 0]
      }
    }

    // Always refresh stats and trigger UI update to ensure calendar displays correctly
    refreshStats()
    DispatchQueue.main.async {
      self.objectWillChange.send()  // Trigger UI update
    }
  }

  func updateCurrentDayLive(
    with times: [Int: TimeInterval], selectedIndex: Int, currentStartTime: Date,
    forceUpdate: Bool = false
  ) {
    // Throttle update để tránh tính toán quá thường xuyên cho UI
    // Cho phép update ngay lập tức khi selectedIndex thay đổi
    let now = Date()
    let shouldUpdate = forceUpdate || now.timeIntervalSince(lastLiveUpdate) >= 1.0 / 60.0  // 60 FPS cho live data

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
