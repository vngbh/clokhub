import SwiftUI

struct ContentView: View {
  @EnvironmentObject var statsVM: PieStatsViewModel

  let namespace: Namespace.ID

  @State private var titleOpacity: Double = 0  // Add state for title opacity

  @State private var selectedIndex = 2
  @State private var accumulatedTimes: [Int: TimeInterval] = [0: 0, 1: 0, 2: 0]
  @State private var currentStartTime = Date()
  @State private var currentTime = Date()
  @State private var chartRotation: Double = 60
  @State private var pieOpacity: Double = 1.0
  @State private var hasResetToday = false
  @State private var lastResetCheck = Date.distantPast  // For debouncing notifications and reset checks

  private let timer = Timer.publish(every: 1 / 30, on: .main, in: .common).autoconnect()  // 30 FPS cho smooth UI

  private let pastelColors = AppColors.pastelColors
  private let standardTextColor = AppColors.standardTextColor

  var body: some View {
    GeometryReader { geo in
      let pieSize = geo.size.width * 0.32
      let fullDiameter = geo.size.width

      VStack {
        Text("divclok")
          .matchedGeometryEffect(id: "logoText", in: namespace, isSource: false)
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
        cachedStartHour = UserDefaults.standard.integer(forKey: "startHour")
        cachedStartMinute = UserDefaults.standard.integer(forKey: "startMinute")

        // Animate the title opacity after a short delay to match the matchedGeometryEffect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          withAnimation(.easeIn(duration: 0.8)) {
            titleOpacity = 1
          }
        }

        NotificationCenter.default.addObserver(
          forName: UIApplication.willResignActiveNotification, object: nil, queue: .main
        ) { _ in
          saveCurrentState()
        }
        NotificationCenter.default.addObserver(
          forName: UIApplication.willTerminateNotification, object: nil, queue: .main
        ) { _ in
          saveCurrentState()
        }
        NotificationCenter.default.addObserver(
          forName: Notification.Name("ResetTimeChanged"), object: nil, queue: .main
        ) { _ in
          // Prevent multiple rapid updates with debounce
          let now = Date()
          if now.timeIntervalSince(lastResetCheck) >= 0.1 {  // 100ms debounce
            cachedStartHour = UserDefaults.standard.integer(forKey: "startHour")
            cachedStartMinute = UserDefaults.standard.integer(forKey: "startMinute")
            statsVM.invalidateLogicalKeyCache()
            print("⚙️ Reset time changed to \(cachedStartHour):\(cachedStartMinute)")
            lastResetCheck = now
          }
        }
      }
      .onDisappear {
        saveCurrentState()
      }
      .onReceive(timer) { _ in
        currentTime = Date()

        // Chỉ check reset mỗi giây để tránh tải CPU cao
        if Date().timeIntervalSince(lastResetCheck) >= 1.0 {
          checkResetIfNeeded()
          lastResetCheck = Date()
        }

        // Update currentDayLive với tần suất cao để UI mượt
        statsVM.updateCurrentDayLive(
          with: accumulatedTimes, selectedIndex: selectedIndex, currentStartTime: currentStartTime)
      }
      .onAppear {
        withAnimation(.easeIn(duration: 1.0)) {
          titleOpacity = 1.0  // Fade in the title
        }
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
          .opacity(pieOpacity)

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

              // Force update ngay lập tức khi chuyển slice
              statsVM.updateCurrentDayLive(
                with: accumulatedTimes, selectedIndex: selectedIndex,
                currentStartTime: currentStartTime, forceUpdate: true)

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
    if UserDefaults.standard.object(forKey: "startHour") == nil {
      UserDefaults.standard.set(22, forKey: "startHour")
      UserDefaults.standard.set(0, forKey: "startMinute")
    }
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

    let lastResetTS = UserDefaults.standard.double(forKey: "lastResetDate")
    if lastResetTS > 0 {
      var calendar = Calendar.current
      calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
      hasResetToday = calendar.isDate(
        Date(timeIntervalSince1970: lastResetTS),
        inSameDayAs: Date()
      )
    }

    resetIfNeeded()
    currentStartTime = Date()
    chartRotation = -((Double(selectedIndex) * 120 + 60).truncatingRemainder(dividingBy: 360))
  }

  private func checkResetIfNeeded() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current

    let now = Date()
    let h = UserDefaults.standard.integer(forKey: "startHour")
    let m = UserDefaults.standard.integer(forKey: "startMinute")

    let currentHour = calendar.component(.hour, from: now)
    let currentMinute = calendar.component(.minute, from: now)

    let currentTotalMinutes = currentHour * 60 + currentMinute
    let resetTotalMinutes = h * 60 + m

    let comps = calendar.dateComponents([.year, .month, .day], from: now)
    var resetComponents = DateComponents()
    resetComponents.year = comps.year
    resetComponents.month = comps.month
    resetComponents.day = comps.day
    resetComponents.hour = h
    resetComponents.minute = m
    resetComponents.second = 0
    resetComponents.timeZone = calendar.timeZone

    let todayReset = calendar.date(from: resetComponents)!
    let lastResetTS = UserDefaults.standard.double(forKey: "lastResetDate")

    let hasPassedResetTime = currentTotalMinutes >= resetTotalMinutes
    let hasResetAfterTodayReset =
      lastResetTS > 0 && Date(timeIntervalSince1970: lastResetTS) >= todayReset

    let needsReset = hasPassedResetTime && !hasResetAfterTodayReset

    if needsReset {
      let currentTotalTime =
        accumulatedTimes.values.reduce(0, +) + now.timeIntervalSince(currentStartTime)

      if currentTotalTime > 0 {
        let saveDate = calendar.date(byAdding: .second, value: -1, to: todayReset)!
        let keyToSave = statsVM.getLogicalKey(for: saveDate)

        if statsVM.repo.fetch(by: keyToSave) == nil {
          statsVM.recordCurrentDayStat(for: saveDate)
        }
      }

      withAnimation(.easeOut(duration: 0.4)) {
        pieOpacity = 0.0
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        accumulatedTimes = [0: 0, 1: 0, 2: 0]
        currentStartTime = now
        statsVM.resetCurrentDay()
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastResetDate")

        withAnimation(.easeIn(duration: 0.4)) {
          pieOpacity = 1.0
        }
      }
    }
  }

  private func resetIfNeeded() {
    checkResetIfNeeded()
  }

  private func recordCurrentStat() {
    let todayKey = statsVM.getLogicalKey(for: Date())
    let totalTime = accumulatedTimes.values.reduce(0, +)
    let percents = (0..<3).map { i in
      let t = accumulatedTimes[i, default: 0]
      return totalTime > 0 ? t / totalTime : 0
    }
    let repo = PieStatsRepository()
    repo.saveOrUpdate(date: todayKey, values: percents)
  }

  private func saveDayStatToDB() {
    let todayKey = statsVM.getLogicalKey(for: Date())
    let totalTime =
      accumulatedTimes.values.reduce(0, +) + currentTime.timeIntervalSince(currentStartTime)
    let percents = (0..<3).map { i in
      let t =
        accumulatedTimes[i, default: 0]
        + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
      return totalTime > 0 ? t / totalTime : 0
    }

    print("📥 Saving to CoreData: \(percents)")

    let repo = PieStatsRepository()
    repo.saveOrUpdate(date: todayKey, values: percents)
  }

  @State private var cachedStartHour: Int = UserDefaults.standard.integer(forKey: "startHour")
  @State private var cachedStartMinute: Int = UserDefaults.standard.integer(forKey: "startMinute")
}

#Preview {
  ContentView(namespace: Namespace().wrappedValue)
    .environmentObject(PieStatsViewModel())
}
