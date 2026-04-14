import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  let container: NSPersistentContainer

  private init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "clokhubModel")
    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores { desc, error in
      if let error = error {
        fatalError("Unresolved Core Data error: \(error)")
      }
    }
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }

  var context: NSManagedObjectContext {
    container.viewContext
  }
}
