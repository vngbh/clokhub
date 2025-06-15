import Foundation

final class PieStatsLoader {
    static func loadMockStats() -> [String: [Double]] {
        guard
            let url = Bundle.main.url(forResource: "dummy_stats", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([DayStat].self, from: data)
        else {
            return [:]
        }

        return Dictionary<String, [Double]>(uniqueKeysWithValues: items.map { ($0.date, $0.values) })
    }
}
