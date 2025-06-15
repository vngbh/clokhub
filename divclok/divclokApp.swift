import SwiftUI

@main
struct divclokApp: App {
  @StateObject private var statsVM = PieStatsViewModel()

  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(statsVM)
    }
  }
}
