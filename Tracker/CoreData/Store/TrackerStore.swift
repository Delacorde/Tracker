
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
    func updatePinStatus(for trackerID: UUID, isPinned: Bool) throws
    func updateTracker(
        _ tracker: Tracker,
        withCategory categoryTitle: String
    ) throws
}

final class TrackerStore: NSObject, TrackerStoreProtocol {

    private let context: NSManagedObjectContext

    weak var delegate: TrackerStoreDelegate?

    private(set) var trackers: [Tracker] = []

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

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

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        updateTrackersArray()
    }

    // MARK: - Update Trackers

    private func updateTrackersArray() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            trackers = []
            return
        }

        trackers = fetchedObjects.compactMap { coreDataObject in
            try? tracker(from: coreDataObject)
        }
    }

    // MARK: - Decode Tracker

    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {

        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let scheduleString = trackerCoreData.schedule as? String
        else {
            throw StoreError.decodingError
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

    // MARK: - Create Tracker

    func makeTracker(from tracker: Tracker, in categoryTitle: String) throws {

        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()

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
        trackerEntity.isPinned = tracker.isPinned

        let scheduleString = tracker.schedule
            .map { String($0.rawValue) }
            .joined(separator: ",")

        trackerEntity.schedule = scheduleString as NSString
        trackerEntity.category = category

        try context.save()
    }

    // MARK: - Delete Tracker

    func deleteTracker(with id: UUID) throws {

        let request: NSFetchRequest<TrackerCoreData> =
            TrackerCoreData.fetchRequest()

        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )

        let trackersToDelete = try context.fetch(request)

        guard let trackerToDelete = trackersToDelete.first else {
            return
        }

        context.delete(trackerToDelete)

        try context.save()
    }
    // MARK: - Update Pin Status

    func updatePinStatus(for trackerID: UUID, isPinned: Bool) throws {
        let request: NSFetchRequest<TrackerCoreData> =
            TrackerCoreData.fetchRequest()

        request.predicate = NSPredicate(
            format: "id == %@",
            trackerID as CVarArg
        )

        let trackersToUpdate = try context.fetch(request)

        guard let tracker = trackersToUpdate.first else {
            throw StoreError.decodingError
        }

        tracker.isPinned = isPinned

        try context.save()
    }
    
    // MARK: - Update Tracker
    func updateTracker(
        _ tracker: Tracker,
        withCategory categoryTitle: String
    ) throws {

        let trackerRequest: NSFetchRequest<TrackerCoreData> =
            TrackerCoreData.fetchRequest()

        trackerRequest.predicate = NSPredicate(
            format: "id == %@",
            tracker.id as CVarArg
        )

        trackerRequest.fetchLimit = 1

        guard let trackerEntity = try context.fetch(trackerRequest).first else {
            throw StoreError.decodingError
        }

        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()

        categoryRequest.predicate = NSPredicate(
            format: "title == %@",
            categoryTitle
        )

        let categories = try context.fetch(categoryRequest)

        let category: TrackerCategoryCoreData

        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            category = newCategory
        }

        trackerEntity.name = tracker.name
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji

        let scheduleString = tracker.schedule
            .map { String($0.rawValue) }
            .joined(separator: ",")

        trackerEntity.schedule = scheduleString as NSString

        trackerEntity.category = category

        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        updateTrackersArray()
        delegate?.trackerStoreDidUpdate(self)
    }
}
