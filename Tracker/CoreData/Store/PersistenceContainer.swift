import CoreData

final class PersistenceContainer {

    let trackerStore: TrackerStore

    let categoryStore: TrackerCategoryStore

    let recordStore: TrackerRecordStore

    let context: NSManagedObjectContext

    private let container: NSPersistentContainer

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(name: "CoreData")

        if inMemory {

            let description = NSPersistentStoreDescription()

            description.type = NSInMemoryStoreType

            container.persistentStoreDescriptions = [description]

        }

        let loadExpectation = DispatchSemaphore(value: 0)

        var loadError: Error?

        container.loadPersistentStores { _, error in

            loadError = error

            loadExpectation.signal()

        }

        loadExpectation.wait()

        if let error = loadError {

            fatalError("Failed to load Core Data: \(error)")

        }

        context = container.viewContext

        context.automaticallyMergesChangesFromParent = true

        trackerStore = TrackerStore(context: context)

        categoryStore = TrackerCategoryStore(context: context)

        recordStore = TrackerRecordStore(context: context)

    }

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
