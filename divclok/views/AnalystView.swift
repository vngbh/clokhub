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

      // // Show current logical day indicator
      // Text("Today: \(todayLogicalKey)")
      //   .font(.subheadline)
      //   .foregroundColor(.gray)
      //   .padding(.bottom, 8)

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
    let pastelGreen = Color(red: 167 / 255, green: 233 / 255, blue: 211 / 255)  // pastel xanh lá
    return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
      let weekdaySymbols = jstCalendar.shortWeekdaySymbols
      ForEach(weekdaySymbols.indices, id: \.self) { i in
        let isWeekend = (i == 0 || i == 6)
        Text(weekdaySymbols[i].prefix(3))
          .font(.caption2.weight(.semibold))
          .foregroundColor(isWeekend ? pastelGreen : .gray)
          .frame(maxWidth: .infinity)
      }

      ForEach(0..<totalCells, id: \.self) { i in
        if i < firstWeekday - 1 {
          Color.clear.frame(height: 78)
        } else {
          cellView(
            for: i, firstWeekday: firstWeekday, firstOfMonth: firstOfMonth,
            todayLogicalKey: todayLogicalKey, weekendColor: pastelGreen)
        }
      }
    }
    .padding(.horizontal, 8)
  }

  private func cellView(
    for index: Int, firstWeekday: Int, firstOfMonth: Date, todayLogicalKey: String,
    weekendColor: Color
  ) -> some View {
    let day = index - firstWeekday + 2
    // Đảm bảo ngày của cell là 00:00 JST
    var comps = jstCalendar.dateComponents([.year, .month], from: firstOfMonth)
    comps.day = day
    comps.hour = 0
    comps.minute = 0
    comps.second = 0
    comps.timeZone = jstCalendar.timeZone
    let date = jstCalendar.date(from: comps)!

    // So sánh bằng string hiển thị (ví dụ "June 15")
    let df = DateFormatter()
    df.dateFormat = "MMMM d"
    df.timeZone = jstCalendar.timeZone
    df.locale = Locale(identifier: "en_US")
    let cellDayString = df.string(from: date)

    // Lấy ngày logic hiện tại (00:00 JST)
    let logicKeyDate: Date = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      formatter.timeZone = jstCalendar.timeZone
      return formatter.date(from: todayLogicalKey) ?? date
    }()
    let logicDayString = df.string(from: logicKeyDate)

    let isFocusDay = cellDayString == logicDayString

    // Cho calendar cells, sử dụng trực tiếp ngày của cell làm key
    // Không áp dụng logic reset time vì dữ liệu đã được lưu với key chính xác
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = jstCalendar.timeZone
    let logicalKey = formatter.string(from: date)

    // Nếu là ngày logic hiện tại, hiển thị real-time data
    let displayData: [Double]? = {
      if isFocusDay {
        // Real-time data cho ngày hiện tại
        let total = statsVM.currentDayLive.reduce(0, +)
        return total > 0 ? statsVM.currentDayLive.map { $0 / total } : nil
      } else {
        // Dữ liệu đã lưu cho các ngày khác
        return statsVM.dailyStats[logicalKey]
      }
    }()

    // Tô màu vàng cam cho Chủ nhật và Thứ bảy
    let weekday = jstCalendar.component(.weekday, from: date)
    let isWeekend = (weekday == 1 || weekday == 7)
    let textColor: Color = isFocusDay ? .red : (isWeekend ? weekendColor : standardTextColor)

    return VStack(spacing: 6) {
      Text("\(day)")
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(textColor)
        .frame(width: 24, height: 24)
      if let data = displayData {
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

#Preview {
  NavigationStack {
    AnalystView()
      .environmentObject(PieStatsViewModel())
  }
}
