import CoreData
import Foundation

extension DayStat {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<DayStat> {
    return NSFetchRequest<DayStat>(entityName: "DayStat")
  }

  @NSManaged public var date: String?
  @NSManaged public var values: [Double]?  // Must be Transformable with NSSecureUnarchiveFromData

}

extension DayStat: Identifiable {}
