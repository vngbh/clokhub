import SwiftUI

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
    var startAngle: Angle
    var sweep: Angle

    func path(in rect: CGRect) -> Path {
        let mid = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        return Path { p in
            p.addArc(
                center: mid, radius: r,
                startAngle: startAngle, endAngle: startAngle + sweep, clockwise: false
            )
        }
    }
}
