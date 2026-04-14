import SwiftUI

struct LaunchView: View {
  @State private var showLogo = false
  @State private var hideLogo = false
  @State private var showContent = false
  @State private var overlayOpacity = 1.0
  @State private var hideOverlay = false

  @Namespace private var logoNamespace

  var body: some View {
    ZStack {
      Color.white.ignoresSafeArea()

      if showContent {
        NavigationStack {
          ContentView(namespace: logoNamespace)
        }
      }

      if showContent && !hideOverlay {
        Color.white
          .ignoresSafeArea()
          .opacity(overlayOpacity)
      }

      if !hideLogo {
        logoView
      }
    }
    .onAppear {
      startLaunchSequence()
    }
  }

  private var logoView: some View {
    VStack(spacing: 8) {
      Image("LaunchLogo")
        .resizable()
        .scaledToFit()
        .frame(width: 140, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .padding(.bottom, 36)

      Text("clokhub")
        .matchedGeometryEffect(id: "logoText", in: logoNamespace, isSource: !showContent)
        .font(.system(size: 36, weight: .bold))
        .foregroundColor(AppColors.standardTextColor)
        .opacity(hideOverlay ? 0 : 1)

      Text("Powered by vngbh")
        .font(.system(size: 12))
        .foregroundColor(AppColors.standardTextColor).opacity(0.3)
    }
    .offset(y: -40)
    .opacity(showLogo ? 1 : 0)
    .scaleEffect(showLogo ? 1.0 : 0.95)
    .animation(.easeInOut(duration: 1.4), value: showLogo)
  }

  private func startLaunchSequence() {
    // 1. Fade in logo
    withAnimation(.easeIn(duration: 1.4)) {
      showLogo = true
    }

    // 2. Wait 3.3s → fade out logo
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
      withAnimation(.easeOut(duration: 1.4)) {
        showLogo = false
      }
    }

    // 3. Show main content
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.7) {
      showContent = true

      // 4. Fade out overlay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.easeOut(duration: 1.2)) {
          overlayOpacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
          hideOverlay = true
          hideLogo = true
        }
      }
    }
  }
}

#Preview {
  LaunchView()
    .environmentObject(PieStatsViewModel())
}
