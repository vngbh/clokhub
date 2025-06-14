import SwiftUI

struct LaunchView: View {
    @State private var showLogo       = false
    @State private var hideLogo       = false
    @State private var showContent    = false
    @State private var overlayOpacity = 1.0
    @State private var hideOverlay    = false
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
                VStack(spacing: 8) {
                    Image("LaunchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240) // 👈 to hơn trước

                    Text("divclok")
                        .matchedGeometryEffect(id: "logo", in: logoNamespace)
                        .font(.system(size:36, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.8))

                    Text("Powered by vngbh")
                        .font(.system(size: 12))
                        .foregroundColor(Color.black.opacity(0.4))
                }
                .offset(y: -40) // 👈 nhích lên trên
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 1.4), value: showLogo) // 👈 fade in dài hơn 0.5s
            }
        }
        .onAppear {
            // 1. Fade in (1.4s)
            withAnimation(.easeIn(duration: 1.4)) {
                showLogo = true
            }

            // 2. Wait 2.9s → fade out (1.4s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeOut(duration: 1.4)) {
                    showLogo = false
                }
            }

            // 3. Show content after fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.7) {
                showContent = true

                // 4. Fade white overlay
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
}

#Preview {
    LaunchView()
}
