import SwiftUI

struct CountUpTimerTextWithSeconds: View {
    let totalSeconds: TimeInterval
    private let standardTextColor = AppColors.standardTextColor

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
