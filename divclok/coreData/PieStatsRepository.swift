import CoreData
import Foundation

final class PieStatsRepository {
  private let context = PersistenceController.shared.context

  func fetch(by date: String) -> [Double]? {
    let req: NSFetchRequest<DayStat> = DayStat.fetchRequest()
    req.predicate = NSPredicate(format: "date == %@", date)
    guard let entity = try? context.fetch(req).first,
      let values = entity.values
    else {
      return nil
    }
    return values
  }

  func saveOrUpdate(date: String, values: [Double]) {
    let req: NSFetchRequest<DayStat> = DayStat.fetchRequest()
    req.predicate = NSPredicate(format: "date == %@", date)

    let entity = (try? context.fetch(req))?.first ?? DayStat(context: context)
    entity.date = date
    entity.values = values
    try? context.save()
  }

  func fetchAll() -> [String: [Double]] {
    let req: NSFetchRequest<DayStat> = DayStat.fetchRequest()
    guard let result = try? context.fetch(req) else { return [:] }

    for item in result {
      print("📊 \(item.date ?? "nil") - \(item.values ?? [])")
    }

    let dict = result.compactMap { entity -> (String, [Double])? in
      guard let date = entity.date,
        let values = entity.values
      else {
        return nil
      }
      return (date, values)
    }
    return Dictionary(uniqueKeysWithValues: dict)
  }
}
