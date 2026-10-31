import CoreData
import UIKit

final class PersistenceContainer {
    let trackerStore: TrackerStore
    let categoryStore: CategoryStore
    let recordStore:  TrackerRecordStore
    
    private let context: NSManagedObjectContext
    
    private let container: NSPersistentContainer
    
    init() {
        // Инициализация контейнера
        container = NSPersistentContainer(name: "AppModel")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        self.trackerStore = TrackerStore(context: context)
        self.categoryStore = CategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
    }
    
    //етод сохранения
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
