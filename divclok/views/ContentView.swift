import SwiftUI

struct ContentView: View {
  let namespace: Namespace.ID

  @State private var selectedIndex = 2
  @State private var accumulatedTimes: [Int: TimeInterval] = [0: 0, 1: 0, 2: 0]
  @State private var currentStartTime = Date()
  @State private var currentTime = Date()
  @State private var chartRotation: Double = 60

  private let timer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()

  private let pastelColors = AppColors.pastelColors
  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    GeometryReader { geo in
      let pieSize = geo.size.width * 0.32
      let fullDiameter = geo.size.width

      VStack {
        Text("divclok")
          .matchedGeometryEffect(id: "logo", in: namespace)
          .font(.largeTitle.bold())
          .foregroundColor(standardTextColor)
          .padding(.top, 30)

        Spacer()

        pieChartSection(pieSize: pieSize)
        Spacer()

        interactivePie(fullDiameter: fullDiameter)
        Spacer()

        bottomMenu
      }
      .onAppear {
        loadSavedState()
        currentTime = Date()
      }
      .onDisappear {
        saveCurrentState()
      }
      .onReceive(timer) {
        currentTime = $0
        checkResetIfNeeded()
      }
    }
  }

  // MARK: - UI Sections

  private func pieChartSection(pieSize: CGFloat) -> some View {
    let totalTime =
      accumulatedTimes.values.reduce(0, +) + currentTime.timeIntervalSince(currentStartTime)
    let percents = (0..<3).map { i in
      let t =
        accumulatedTimes[i, default: 0]
        + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
      return totalTime > 0 ? t / totalTime : 0
    }

    return HStack(alignment: .center, spacing: 34) {
      ZStack(alignment: .center) {
        PieChartView(percentages: percents, colors: pastelColors)
          .frame(width: pieSize, height: pieSize)
          .rotationEffect(.degrees(chartRotation))

        Circle()
          .fill(Color.white)
          .frame(width: pieSize * 0.75, height: pieSize * 0.75)

        Text(Formatters.hhmm(from: totalTime))
          .font(.system(size: 18, weight: .bold, design: .monospaced))
          .foregroundColor(standardTextColor)
      }

      VStack(alignment: .leading, spacing: 12) {
        ForEach(0..<3, id: \.self) { i in
          let t =
            accumulatedTimes[i, default: 0]
            + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
          let pct = percents[i] * 100
          HStack(spacing: 12) {
            Circle()
              .fill(pastelColors[i])
              .frame(width: 12, height: 12)
            Text("\(Formatters.hms(from: t)) (\(String(format: "%.f", pct))%)")
              .font(.system(size: 12, design: .monospaced))
              .foregroundColor(standardTextColor)
          }
        }
      }
      .frame(maxWidth: 140, alignment: .leading)
    }
    .padding(.horizontal)
  }

  private func interactivePie(fullDiameter: CGFloat) -> some View {
    let sliceAngle = 360.0 / 3
    let radius = fullDiameter * 0.52
    let offsetDist: CGFloat = 28

    return ZStack {
      ForEach(0..<3, id: \.self) { i in
        let start = Double(i) * sliceAngle
        let mid = start + sliceAngle / 2
        let isSel = selectedIndex == i

        PieSlice(startAngle: .degrees(start), endAngle: .degrees(start + sliceAngle))
          .fill(pastelColors[i])
          .overlay(
            PieSlice(startAngle: .degrees(start), endAngle: .degrees(start + sliceAngle))
              .stroke(
                pastelColors[i],
                style: StrokeStyle(
                  lineWidth: 60,
                  lineCap: .round,
                  lineJoin: .round
                )
              )
          )
          .frame(width: radius, height: radius * 2)
          .rotationEffect(.degrees(-90))
          .offset(
            x: cos((mid - 90).toRadians()) * offsetDist * (isSel ? 2.4 : 1.4),
            y: sin((mid - 90).toRadians()) * offsetDist * (isSel ? 2.4 : 1.4)
          )
          .onTapGesture {
            withAnimation(.easeInOut) {
              let now = Date()
              let elapsed = now.timeIntervalSince(currentStartTime)
              accumulatedTimes[selectedIndex, default: 0] += elapsed

              let delta = (i - selectedIndex + 3) % 3
              selectedIndex = i
              currentStartTime = now
              currentTime = now

              let step = 360.0 / 3.0
              switch delta {
              case 1: chartRotation -= step
              case 2: chartRotation += step
              default: break
              }
            }
          }
      }
      .rotationEffect(.degrees(chartRotation))
      .frame(width: fullDiameter, height: fullDiameter)

      Circle()
        .fill(Color.white)
        .frame(width: fullDiameter * 0.45, height: fullDiameter * 0.45)

      let segmentTime =
        accumulatedTimes[selectedIndex, default: 0]
        + currentTime.timeIntervalSince(currentStartTime)
      let progress = currentTime.timeIntervalSince1970.truncatingRemainder(dividingBy: 1)

      CountUpTimerTextWithSeconds(totalSeconds: segmentTime)

      FullColorCircle(color: pastelColors[selectedIndex])
        .frame(width: fullDiameter * 0.45, height: fullDiameter * 0.45)

      GrayTrailArc(progress: progress, radius: fullDiameter * 0.3 / 2)
    }
  }

  private var bottomMenu: some View {
    HStack {
      Spacer()
      NavigationLink(destination: AnalystView()) {
        MenuButton(icon: "chart.pie.fill")
      }
      Spacer()
      NavigationLink(destination: PersonalView()) {
        MenuButton(icon: "person.crop.circle")
      }
      Spacer()
      NavigationLink(destination: SettingsView()) {
        MenuButton(icon: "gearshape")
      }
      Spacer()
    }
    .padding(.bottom, 8)
    .font(.caption)
  }

  // MARK: - State persistence

  private func saveCurrentState() {
    let elapsed = Date().timeIntervalSince(currentStartTime)
    accumulatedTimes[selectedIndex, default: 0] += elapsed

    let encodedTimes = Dictionary(
      uniqueKeysWithValues: accumulatedTimes.map { (String($0.key), $0.value) })
    UserDefaults.standard.set(encodedTimes, forKey: "accumulatedTimes")
    UserDefaults.standard.set(selectedIndex, forKey: "selectedIndex")
    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastSavedTime")
  }

  private func loadSavedState() {
    if let saved = UserDefaults.standard.dictionary(forKey: "accumulatedTimes")
      as? [String: TimeInterval]
    {
      accumulatedTimes = saved.reduce(into: [:]) { result, pair in
        if let key = Int(pair.key) {
          result[key] = pair.value
        }
      }
    }

    selectedIndex = UserDefaults.standard.integer(forKey: "selectedIndex")
    let lastSaved = UserDefaults.standard.double(forKey: "lastSavedTime")
    if lastSaved > 0 {
      let elapsedSince = Date().timeIntervalSince1970 - lastSaved
      accumulatedTimes[selectedIndex, default: 0] += elapsedSince
    }

    resetIfNeeded()
    currentStartTime = Date()
    chartRotation = -((Double(selectedIndex) * 120 + 60).truncatingRemainder(dividingBy: 360))
  }

  private func checkResetIfNeeded() {
    let now = Date()
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

    let current = calendar.dateComponents([.year, .month, .day], from: now)
    let resetTime = calendar.date(
      from: DateComponents(year: current.year, month: current.month, day: current.day, hour: 22))!
    let lastResetTimestamp = UserDefaults.standard.double(forKey: "lastResetDate")
    let lastResetDate = Date(timeIntervalSince1970: lastResetTimestamp)

    if now >= resetTime && lastResetDate < resetTime {
      accumulatedTimes = [0: 0, 1: 0, 2: 0]
      currentStartTime = now
      UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastResetDate")
    }
  }

  private func resetIfNeeded() {
    checkResetIfNeeded()
  }
}

#Preview {
  ContentView(namespace: Namespace().wrappedValue)
    .environmentObject(PieStatsViewModel())
}
