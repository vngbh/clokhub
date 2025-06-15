import SwiftUI

@main
struct divclokApp: App {
  @StateObject var statsVM = PieStatsViewModel()

  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(statsVM)
    }
  }
}
