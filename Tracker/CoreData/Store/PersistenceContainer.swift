import CoreData


final class PersistenceContainer {
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore:  TrackerRecordStore
    
    let context: NSManagedObjectContext
    
    private let container: NSPersistentContainer
    
    init() {
        // Инициализация контейнера
        container = NSPersistentContainer(name: "CoreData")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        self.trackerStore = TrackerStore(context: context)
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
    }
    
    //метод сохранения
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
