import Foundation

extension Date {
  func toYYYYMMDD() -> String {
    DateFormatter.yyyyMMdd.string(from: self)
  }
}

extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    df.locale = Locale(identifier: "en_US_POSIX")
    df.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
    return df
  }()
}
