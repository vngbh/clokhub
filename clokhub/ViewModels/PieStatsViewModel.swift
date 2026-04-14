import Foundation

final class PieStatsViewModel: ObservableObject {
  @Published var dailyStats: [String: [Double]]
  @Published var currentDayLive: [Double] = [0, 0, 0]

  // Cache only the current day key.
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
  }

  func getLogicalKey(for date: Date = Date()) -> String {
    // Cache only calls that target the current date.
    let now = Date()
    if date.timeIntervalSince(now) > -1 && date.timeIntervalSince(now) < 1 {
      if Date().timeIntervalSince(lastKeyUpdate) < 60 && !cachedTodayKey.isEmpty {
        return cachedTodayKey
      }
    }

    let startHour = UserDefaults.standard.integer(forKey: "startHour")
    let startMinute = UserDefaults.standard.integer(forKey: "startMinute")
    let resetTotalMinutes = startHour * 60 + startMinute

    // Use JST directly for logical day boundaries.
    let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
    var jstCalendarCopy = Calendar.current
    jstCalendarCopy.timeZone = jstTimeZone

    // Read the current time in JST.
    let currentHour = jstCalendarCopy.component(.hour, from: date)
    let currentMinute = jstCalendarCopy.component(.minute, from: date)
    let currentTotalMinutes = currentHour * 60 + currentMinute

    // Calculate logical date in JST
    let logicDate: Date
    if currentTotalMinutes >= resetTotalMinutes {
      // After the daily reset time, use the current date.
      logicDate = date

    } else {
      // Before the daily reset time, keep tracking against the previous date.
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

  func recordCurrentDayStat(for date: Date = Date()) {
    let key = getLogicalKey(for: date)
    let total = currentDayLive.reduce(0, +)

    if total == 0 {
      return
    }

    // Store percentages for pie chart rendering.
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
      print("Stats refreshed: \(oldCount) -> \(newCount) entries")
    }

    // Core Data stores percentages; ContentView owns the live raw time values.
  }

  func resetCurrentDay() {
    currentDayLive = [0, 0, 0]
    cachedTodayKey = ""
    lastKeyUpdate = Date.distantPast
    lastLiveUpdate = Date.distantPast
  }

  func invalidateLogicalKeyCache() {
    // Preserve the previous logical day before invalidating the cache.
    let oldLogicalKey = cachedTodayKey

    cachedTodayKey = ""
    lastKeyUpdate = Date.distantPast

    let newLogicalKey = getLogicalKey(for: Date())

    if !oldLogicalKey.isEmpty && oldLogicalKey != newLogicalKey {
      let total = currentDayLive.reduce(0, +)
      if total > 0 {
        let percents = currentDayLive.map { total > 0 ? $0 / total : 0 }
        repo.saveOrUpdate(date: oldLogicalKey, values: percents)

        dailyStats[oldLogicalKey] = percents

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
    // Throttle updates while still allowing immediate slice changes.
    let now = Date()
    let shouldUpdate = forceUpdate || now.timeIntervalSince(lastLiveUpdate) >= 1.0 / 60.0

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
