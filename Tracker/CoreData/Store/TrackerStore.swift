import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ store: TrackerStoreProtocol)
}

protocol TrackerStoreProtocol {
    var trackers: [Tracker] { get }
    var delegate: TrackerStoreDelegate? { get set }
    func makeTracker(from tracker: Tracker, in category: TrackerCategoryCoreData) throws
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
            throw NSError(domain: "TrackerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode Tracker"])
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
    
    // Создание и сохранение нового трекера
    func makeTracker(from tracker: Tracker, in category: TrackerCategoryCoreData) throws {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as? NSObject
        trackerEntity.category = category
        
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
