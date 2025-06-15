import Foundation

final class PieStatsViewModel: ObservableObject {
    @Published var dailyStats: [String: [Double]] = PieStatsLoader.loadMockStats()
    @Published var currentDayLive: [Double] = [0, 0, 0]

    func stats(for date: Date) -> [Double]? {
        let key = date.toYYYYMMDD()
        return Calendar.current.isDateInToday(date) ? currentDayLive : dailyStats[key]
    }
}
