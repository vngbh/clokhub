import SwiftUI

struct ContentView: View {
  let namespace: Namespace.ID

  let pastelColors = [
    Color(red: 248 / 255, green: 187 / 255, blue: 208 / 255),  // hồng
    Color(red: 167 / 255, green: 233 / 255, blue: 211 / 255),  // xanh
    Color(red: 211 / 255, green: 192 / 255, blue: 235 / 255),  // tím

  ]

  let standardTextColor = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)

  let cornerRadius: CGFloat = 5

  @State private var selectedIndex = 2
  @State private var accumulatedTimes: [Int: TimeInterval] = [0: 0, 1: 0, 2: 0]
  @State private var currentStartTime = Date()
  @State private var currentTime = Date()
  @State private var chartRotation: Double = 60

  private let timer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()

  var body: some View {
    GeometryReader { geo in
      let pieSize = geo.size.width * 0.32
      let fullDiameter = geo.size.width

      VStack {
        // Logo
        Text("divclok")
          .matchedGeometryEffect(id: "logo", in: namespace)
          .font(.largeTitle.bold())
          .foregroundColor(standardTextColor)
          .padding(.top, 30)

        Spacer()

        // Pie chart + summary
        let totalTime =
          accumulatedTimes.values.reduce(0, +) + currentTime.timeIntervalSince(currentStartTime)
        let percents = (0..<3).map { i -> Double in
          let t =
            accumulatedTimes[i, default: 0]
            + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
          return totalTime > 0 ? t / totalTime : 0
        }

        HStack(alignment: .center, spacing: 34) {
          ZStack(alignment: .center) {
            PieChartView(percentages: percents, colors: pastelColors)
              .frame(width: pieSize, height: pieSize)
              .rotationEffect(.degrees(chartRotation))

            Circle()
              .fill(Color.white)
              .frame(width: pieSize * 0.75, height: pieSize * 0.75)

            Text(formatHHMM(totalTime))
              .font(.system(size: 18, weight: .bold, design: .monospaced))
              .foregroundColor(standardTextColor)
          }

          VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<3, id: \.self) { i in
              let tInterval =
                accumulatedTimes[i, default: 0]
                + (selectedIndex == i ? currentTime.timeIntervalSince(currentStartTime) : 0)
              let pct = percents[i] * 100
              HStack(spacing: 12) {
                Circle()
                  .fill(pastelColors[i])
                  .frame(width: 12, height: 12)
                Text("\(formatHMS(tInterval)) (\(String(format: "%.f", pct))%)")
                  .font(.system(size: 12, design: .monospaced))
                  .foregroundColor(standardTextColor)
              }
            }
          }
          .frame(maxWidth: 140, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)

        Spacer()

        // Main pie timer
        ZStack {
          let sliceAngle = 360.0 / 3
          let radius = fullDiameter * 0.52
          let offsetDist: CGFloat = 28

          ZStack {
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
                        lineWidth: cornerRadius * 12, lineCap: .round, lineJoin: .round))
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

                    // Tính delta cho rotation
                    let delta = (i - selectedIndex + 3) % 3

                    selectedIndex = i
                    currentStartTime = now
                    currentTime = now

                    let step = 360.0 / 3.0
                    switch delta {
                    case 1:
                      // nhấn bên phải → CCW
                      chartRotation -= step
                    case 2:
                      // nhấn bên trái → CW
                      chartRotation += step
                    default:
                      break
                    }
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
        .frame(width: fullDiameter, height: fullDiameter)
        .onReceive(timer) { currentTime = $0 }

        Spacer()

        // Bottom menu
        HStack {
          Spacer()
          NavigationLink(destination: AdjustView()) {
            menuItem(icon: "slider.horizontal.3")
          }
          Spacer()
          NavigationLink(destination: PersonalView()) {
            menuItem(icon: "person.crop.circle")
          }
          Spacer()
          NavigationLink(destination: SettingsView()) {
            menuItem(icon: "gearshape")
          }
          Spacer()
        }

        .padding(.bottom, 8)
        .font(.caption)
      }
      .onAppear {
        loadSavedState()
        currentTime = Date()
      }
      .onDisappear {
        saveCurrentState()
      }
    }
  }

  // MARK: - Formatters

  private func formatHHMM(_ s: TimeInterval) -> String {
    let total = Int(round(s))
    return String(format: "%02d:%02d", total / 3600, (total % 3600) / 60)
  }

  private func formatHMS(_ s: TimeInterval) -> String {
    let total = Int(round(s))
    return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
  }

  private func menuItem(icon: String) -> some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.system(size: 32, weight: .light))
    }
    .foregroundColor(standardTextColor)

  }

  // MARK: - Lưu và khôi phục trạng thái

  private func saveCurrentState() {
    // Cộng phần thời gian kể từ last start
    let elapsed = Date().timeIntervalSince(currentStartTime)
    accumulatedTimes[selectedIndex, default: 0] += elapsed

    // Lưu dictionary [String: Double]
    let encodedTimes = Dictionary(
      uniqueKeysWithValues: accumulatedTimes.map { (key, val) in
        (String(key), val)
      })
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

    // Tính rotation để slice đang chọn quay lên trên
    let sliceAngle = 360.0 / 3
    let midAngle = (Double(selectedIndex) * sliceAngle + sliceAngle / 2).truncatingRemainder(
      dividingBy: 360)
    chartRotation = 0 - midAngle

    currentStartTime = Date()
  }
}

// MARK: - Subviews & Helpers

struct CountUpTimerTextWithSeconds: View {
  let totalSeconds: TimeInterval
  let standardTextColor = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
  var body: some View {
    let total = Int(round(totalSeconds))
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60

    VStack(spacing: 4) {
      Text(String(format: "%02d:%02d", h, m))
        .font(.system(size: 24, weight: .bold, design: .monospaced))
        .foregroundColor(standardTextColor)
        .padding(.top, 18)
      Text(String(format: "%02d", s))
        .font(.system(size: 12, design: .monospaced))
        .foregroundColor(standardTextColor)
    }
    .multilineTextAlignment(.center)
  }
}

struct FullColorCircle: View {
  let color: Color

  var body: some View {
    Circle()
      .stroke(
        color.opacity(0.9),
        style: StrokeStyle(lineWidth: 24, lineCap: .round)
      )
      .rotationEffect(.degrees(-90))
      .shadow(color: .black.opacity(0.24), radius: 6)
  }
}

struct GrayTrailArc: View {
  let progress: Double
  let radius: CGFloat

  var body: some View {
    TrailShape(
      startAngle: .degrees(progress * 360 - 45),
      sweep: .degrees(90)
    )
    .stroke(
      AngularGradient(
        gradient: Gradient(stops: [
          .init(color: .gray.opacity(0), location: 0),
          .init(color: .gray.opacity(0.8), location: 1),
        ]), center: .center,
        startAngle: .degrees(progress * 360 - 60),
        endAngle: .degrees(progress * 360 + 60)),
      style: StrokeStyle(lineWidth: 6, lineCap: .round)
    )
    .frame(width: radius * 2, height: radius * 2)
  }
}

struct TrailShape: Shape {
  var startAngle: Angle, sweep: Angle
  func path(in rect: CGRect) -> Path {
    let mid = CGPoint(x: rect.midX, y: rect.midY)
    let r = min(rect.width, rect.height) / 2
    return Path { p in
      p.addArc(
        center: mid, radius: r,
        startAngle: startAngle, endAngle: startAngle + sweep, clockwise: false)
    }
  }
}

struct PieSlice: Shape {
  var startAngle: Angle, endAngle: Angle
  func path(in rect: CGRect) -> Path {
    let mid = CGPoint(x: rect.midX, y: rect.midY)
    let r = min(rect.width, rect.height) / 2
    return Path { p in
      p.move(to: mid)
      p.addArc(
        center: mid, radius: r,
        startAngle: startAngle, endAngle: endAngle, clockwise: false)
      p.closeSubpath()
    }
  }
}

struct PieChartView: View {
  let percentages: [Double]
  let colors: [Color]
  var body: some View {
    ZStack {
      ForEach(percentages.indices, id: \.self) { i in
        let start = percentages[..<i].reduce(0, +) * 360
        let sweep = percentages[i] * 360
        PieSlice(
          startAngle: .degrees(start),
          endAngle: .degrees(start + sweep)
        )
        .fill(colors[i])
      }
    }
  }
}

extension Double {
  fileprivate func toRadians() -> Double { self * .pi / 180 }
}

struct ContentView_Previews: PreviewProvider {
  @Namespace static var previewNamespace
  static var previews: some View {
    ContentView(namespace: previewNamespace)
  }
}

struct RootView: View {
  @Namespace private var namespace

  var body: some View {
    NavigationStack {
      ContentView(namespace: namespace)
    }
  }
}
