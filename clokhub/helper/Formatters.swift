import Foundation

enum Formatters {
    static func hhmm(from seconds: TimeInterval) -> String {
        let total = Int(round(seconds))
        return String(format: "%02d:%02d", total / 3600, (total % 3600) / 60)
    }

    static func hms(from seconds: TimeInterval) -> String {
        let total = Int(round(seconds))
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }
}
