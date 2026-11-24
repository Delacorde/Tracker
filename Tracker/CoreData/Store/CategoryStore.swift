
import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStoreDidUpdate(_ store: TrackerCategoryStoreProtocol)
}

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    var delegate: TrackerCategoryStoreDelegate? { get set }
    func makeCategory(from category: TrackerCategory) throws
    func updateCategory(oldTitle: String, newTitle: String) throws
    func deleteCategory(with title: String) throws
    func fetchCategories() throws
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        try? controller.performFetch()
        return controller
    }()
    
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        
        return objects.compactMap { (trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? in
            guard let title = trackerCategoryCoreData.title else { return nil }
            
            let trackersCoreData =
                trackerCategoryCoreData.tracker as? Set<TrackerCoreData> ?? []
            
            let trackers = trackersCoreData.compactMap { (trackerCoreData: TrackerCoreData) -> Tracker? in
                guard
                    let id = trackerCoreData.id,
                    let name = trackerCoreData.name,
                    let color = trackerCoreData.color,
                    let emoji = trackerCoreData.emoji,
                    let scheduleString = trackerCoreData.schedule as? String
                else {
                    return nil
                }
                
                let schedule = WeekDays.decode(from: scheduleString)
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: schedule,
                    isPinned: trackerCoreData.isPinned
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func makeCategory(from category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        
        try context.save()
    }
    
    func updateCategory(oldTitle: String, newTitle: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        request.fetchLimit = 1

        guard let category = try context.fetch(request).first else {
            return
        }

        category.title = newTitle
        try context.save()
    }

    func deleteCategory(with title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        guard let category = try context.fetch(request).first else {
            return
        }

        // Удаляем записи выполнения и сами трекеры категории,
        // чтобы после удаления не оставалось связанных данных.
        let trackers = category.tracker as? Set<TrackerCoreData> ?? []
        
        for tracker in trackers {
            if let trackerId = tracker.id {
                let recordsRequest: NSFetchRequest<TrackerRecordCoreData> =
                    TrackerRecordCoreData.fetchRequest()
                recordsRequest.predicate = NSPredicate(
                    format: "trackerId == %@",
                    trackerId as CVarArg
                )
                
                let records = try context.fetch(recordsRequest)
                records.forEach { context.delete($0) }
            }
            
            context.delete(tracker)
        }

        context.delete(category)
        try context.save()
    }

    func fetchCategories() throws {
        try fetchedResultsController.performFetch()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.categoryStoreDidUpdate(self)
    }
}
