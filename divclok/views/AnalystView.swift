import SwiftUI

struct AnalystView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var statsVM: PieStatsViewModel
  @State private var monthOffset = 0

  // Use computed property instead of state
  private var todayLogicalKey: String {
    statsVM.getLogicalKey(for: Date())
  }

  private let pastelColors = [
    Color(red: 248 / 255, green: 187 / 255, blue: 208 / 255),
    Color(red: 167 / 255, green: 233 / 255, blue: 211 / 255),
    Color(red: 211 / 255, green: 192 / 255, blue: 235 / 255),
  ]

  private let standardTextColor = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)

  // Computed properties for calendar calculations
  private var jstCalendar: Calendar {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
    return calendar
  }

  private var currentMonthDate: Date {
    jstCalendar.date(byAdding: .month, value: monthOffset, to: Date())!
  }

  private var firstOfCurrentMonth: Date {
    let components = jstCalendar.dateComponents([.year, .month], from: currentMonthDate)
    return jstCalendar.date(from: components)!
  }

  private var currentMonthRange: Range<Int> {
    jstCalendar.range(of: .day, in: .month, for: firstOfCurrentMonth)!
  }

  private var currentMonthFirstWeekday: Int {
    jstCalendar.component(.weekday, from: firstOfCurrentMonth)
  }

  private var currentMonthTotalCells: Int {
    currentMonthRange.count + currentMonthFirstWeekday - 1
  }

  var body: some View {
    VStack(alignment: .center, spacing: 12) {
      header(monthDate: currentMonthDate)

      ZStack {
        calendarGrid(
          for: firstOfCurrentMonth,
          range: currentMonthRange,
          firstWeekday: currentMonthFirstWeekday,
          totalCells: currentMonthTotalCells,
          todayLogicalKey: todayLogicalKey
        )
        .id(monthOffset)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: monthOffset)
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding(.top, 40)
    .background(Color.white.ignoresSafeArea())
    .task {
      statsVM.refreshStats()
    }
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ResetTimeChanged"))) {
      _ in
      statsVM.invalidateLogicalKeyCache()
      statsVM.refreshStats()
    }
    .navigationBarBackButtonHidden(true)
    .overlay(
      VStack {
        Spacer()
        HStack {
          Spacer()
          backButton
          Spacer()
        }
        .padding(.bottom, 10)
      }
    )
  }

  private func header(monthDate: Date) -> some View {
    HStack {
      Button(action: { withAnimation { monthOffset -= 1 } }) {
        Image(systemName: "chevron.left")
          .font(.system(size: 24, weight: .medium))
          .foregroundColor(standardTextColor)
      }
      Spacer()
      Text(monthTitle(from: monthDate))
        .font(.system(size: 24, weight: .medium))
        .foregroundColor(standardTextColor)
      Spacer()
      Button(action: { withAnimation { monthOffset += 1 } }) {
        Image(systemName: "chevron.right")
          .font(.system(size: 24, weight: .medium))
          .foregroundColor(standardTextColor)
      }
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }

  private func calendarGrid(
    for firstOfMonth: Date,
    range: Range<Int>,
    firstWeekday: Int,
    totalCells: Int,
    todayLogicalKey: String
  ) -> some View {
    return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
      let weekdaySymbols = jstCalendar.shortWeekdaySymbols
      ForEach(weekdaySymbols, id: \.self) { day in
        Text(day.prefix(3))
          .font(.caption2.weight(.semibold))
          .foregroundColor(.gray)
          .frame(maxWidth: .infinity)
      }

      ForEach(0..<totalCells, id: \.self) { i in
        if i < firstWeekday - 1 {
          Color.clear.frame(height: 78)
        } else {
          cellView(
            for: i, firstWeekday: firstWeekday, firstOfMonth: firstOfMonth,
            todayLogicalKey: todayLogicalKey)
        }
      }
    }
    .padding(.horizontal, 8)
  }

  private func cellView(
    for index: Int, firstWeekday: Int, firstOfMonth: Date, todayLogicalKey: String
  ) -> some View {
    let day = index - firstWeekday + 2
    let date = jstCalendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!

    // Get the logical key specific for this date, not from cache
    let logicalKey = statsVM.getLogicalKey(for: date)
    let data = statsVM.dailyStats[logicalKey]

    // Strict comparison of logical keys
    let isLogicalToday = logicalKey == todayLogicalKey

    return VStack(spacing: 6) {
      Text("\(day)")
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(isLogicalToday ? .red : standardTextColor)  // Only red for logical today
        .frame(width: 24, height: 24)

      if let data = data {
        PieChartView(percentages: data, colors: pastelColors)
          .frame(width: 26, height: 26)
      } else {
        Spacer().frame(height: 26)
      }
    }
    .frame(maxWidth: .infinity, minHeight: 78)
    .background(Color.white)
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    .padding(2)
  }

  private func monthTitle(from date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "LLLL yyyy"
    df.timeZone = jstCalendar.timeZone
    df.locale = Locale(identifier: "en_US")
    return df.string(from: date)
  }

  private var backButton: some View {
    CircleBackButton(action: {
      dismiss()
    })
  }
}
