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
    // Không save nếu tất cả giá trị đều là 0
    let totalTime = values.reduce(0, +)
    if totalTime == 0 {
      print("⚠️ Skipping save for \(date) - no time tracked")
      return
    }

    let req: NSFetchRequest<DayStat> = DayStat.fetchRequest()
    req.predicate = NSPredicate(format: "date == %@", date)

    let entity = (try? context.fetch(req))?.first ?? DayStat(context: context)
    entity.date = date
    entity.values = values

    do {
      try context.save()
      print("💾 Saved stats for \(date): \(values.map { String(format: "%.2f", $0) })")
    } catch {
      print("❌ Failed to save stats: \(error)")
    }
  }

  func fetchAll() -> [String: [Double]] {
    let req: NSFetchRequest<DayStat> = DayStat.fetchRequest()
    guard let result = try? context.fetch(req) else { return [:] }

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

  func deleteAll() {
    let req: NSFetchRequest<NSFetchRequestResult> = DayStat.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: req)

    do {
      try context.execute(deleteRequest)
      try context.save()
      print("🗑️ Deleted all Core Data records")
    } catch {
      print("❌ Failed to delete Core Data: \(error)")
    }
  }
}
