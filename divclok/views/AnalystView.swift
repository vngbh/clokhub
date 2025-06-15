import SwiftUI

struct AnalystView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var statsVM: PieStatsViewModel
  @State private var monthOffset = 0

  private let pastelColors = [
    Color(red: 248 / 255, green: 187 / 255, blue: 208 / 255),
    Color(red: 167 / 255, green: 233 / 255, blue: 211 / 255),
    Color(red: 211 / 255, green: 192 / 255, blue: 235 / 255),
  ]

  private let standardTextColor = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)

  var body: some View {
    let todayLogicalKey = statsVM.getLogicalKey(for: logicalToday())
    let calendar = Calendar.current
    let today = Date()
    let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: today)!
    let components = calendar.dateComponents([.year, .month], from: monthDate)
    let firstOfMonth = calendar.date(from: components)!
    let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
    let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
    let totalCells = range.count + firstWeekday - 1

    VStack(alignment: .center, spacing: 12) {
      header(monthDate: monthDate)

      ZStack {
        calendarGrid(
          for: firstOfMonth,
          range: range,
          firstWeekday: firstWeekday,
          totalCells: totalCells,
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
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
      let weekdaySymbols = Calendar.current.shortWeekdaySymbols
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
          let day = i - firstWeekday + 2
          let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
          let logicalKey = statsVM.getLogicalKey(for: date)
          let data = statsVM.dailyStats[logicalKey]
          let isToday = logicalKey == todayLogicalKey

          VStack(spacing: 6) {
            Text("\(day)")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(isToday ? .red : standardTextColor)
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
      }
    }
    .padding(.horizontal, 8)
  }

  private func monthTitle(from date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "LLLL yyyy"
    df.locale = Locale(identifier: "en_US")
    return df.string(from: date)
  }

  private var backButton: some View {
    Button(action: { dismiss() }) {
      Image(systemName: "chevron.left")
        .font(.system(size: 14, weight: .heavy))
        .foregroundColor(.white)
        .frame(width: 36, height: 36)
        .background(Circle().fill(standardTextColor))
        .shadow(radius: 6)
    }
  }

  private func logicalToday() -> Date {
    let now = Date()
    let calendar = Calendar.current
    let startHour = UserDefaults.standard.integer(forKey: "startHour")
    let startMinute = UserDefaults.standard.integer(forKey: "startMinute")
    let todayReset = calendar.date(
      bySettingHour: startHour, minute: startMinute, second: 0, of: now)!
    if now < todayReset {
      return calendar.date(byAdding: .day, value: -1, to: now)!
    }
    return now
  }
}
