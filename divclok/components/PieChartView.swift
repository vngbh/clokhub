import SwiftUI

struct PieChartView: View {
    let percentages: [Double]
    let colors: [Color]

    var body: some View {
        ZStack {
            ForEach(percentages.indices, id: \.self) { i in
                let start = percentages[..<i].reduce(0, +) * 360
                let sweep = percentages[i] * 360

                PieSlice(startAngle: .degrees(start), endAngle: .degrees(start + sweep))
                    .fill(colors[i])
            }
        }
    }
}
