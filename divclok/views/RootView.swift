import SwiftUI

struct RootView: View {
  @Namespace private var namespace

  var body: some View {
    NavigationStack {
      ContentView(namespace: namespace)
    }
  }
}
