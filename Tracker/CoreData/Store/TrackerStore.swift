import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ store: TrackerStoreProtocol)
}

protocol TrackerStoreProtocol {
    var trackers: [Tracker] { get }
    var delegate: TrackerStoreDelegate? { get set }
    func makeTracker(from tracker: Tracker, in categoryTitle: String) throws
    func deleteTracker(with id: UUID) throws
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
         
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
         
        try? controller.performFetch()
        return controller
    }()
    
    weak var delegate: TrackerStoreDelegate?
    
    private(set) var trackers: [Tracker] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        updateTrackersArray()
    }
    
    private func updateTrackersArray() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            trackers = []
            return
        }
        trackers = fetchedObjects.compactMap { coreDataObject in
            try? self.tracker(from: coreDataObject)
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji
        else {
            throw NSError(
                domain: "TrackerStore",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to decode Tracker"
                ]
            )
        }
         
        let schedule: [WeekDays]?
         
        if let scheduleString = trackerCoreData.schedule as? String {
            schedule = WeekDays.decode(from: scheduleString)
        } else {
            schedule = trackerCoreData.schedule as? [WeekDays]
        }
         
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func makeTracker(from tracker: Tracker, in categoryTitle: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "title == %@",
            categoryTitle
        )
         
        let categories = try context.fetch(request)
         
        let category: TrackerCategoryCoreData
         
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            category = newCategory
        }
         
        let trackerEntity = TrackerCoreData(context: context)
         
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        
        let scheduleString = (tracker.schedule ?? [])
            .map { String($0.rawValue) }
            .joined(separator: ",")
         
        trackerEntity.schedule = scheduleString as NSString
        trackerEntity.category = category
         
        try context.save()
    }
    func deleteTracker(with id: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let trackersToDelete = try context.fetch(request)

        guard let trackerToDelete = trackersToDelete.first else {
            return
        }

        context.delete(trackerToDelete)
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateTrackersArray()
        delegate?.trackerStoreDidUpdate(self)
    }
}
