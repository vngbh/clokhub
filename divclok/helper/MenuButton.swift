import SwiftUI

struct MenuButton: View {
    let icon: String
    private let color = AppColors.standardTextColor

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
        }
        .foregroundColor(color)
    }
}
