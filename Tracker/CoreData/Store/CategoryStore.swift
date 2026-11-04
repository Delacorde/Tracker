import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStoreDidUpdate(_ store: TrackerCategoryStoreProtocol)
}

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    var delegate: TrackerCategoryStoreDelegate? { get set }
    func makeCategory(from category: TrackerCategory) throws
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
                        else { return nil }
                
                let schedule = WeekDays.decode(from: scheduleString)
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
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
    
    func fetchCategories() throws {
        try fetchedResultsController.performFetch()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.categoryStoreDidUpdate(self)
    }
}
