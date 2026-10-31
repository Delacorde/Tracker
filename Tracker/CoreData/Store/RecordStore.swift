import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate(_ store: TrackerRecordStoreProtocol)
}

protocol TrackerRecordStoreProtocol {
    var completedTrackers: Set<TrackerRecord> { get }
    var delegate: TrackerRecordStoreDelegate? { get set }
    func makeRecord(for trackerId: UUID, date: Date) throws
    func removeRecord(for trackerId: UUID, date: Date) throws
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext
    
    // Делаем lazy var, чтобы он создавался безопасно ПОСЛЕ super.init() и имел доступ к self
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private(set) var completedTrackers: Set<TrackerRecord> = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init() // 1. Сначала обязательно вызываем super.init()
        
        updateCompletedTrackers() // 2. Затем заполняем начальный массив записей
    }
    
    private func updateCompletedTrackers() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            completedTrackers = []
            return
        }
        
        completedTrackers = Set(fetchedObjects.compactMap { recordCoreData -> TrackerRecord? in
            guard
                let trackerId = recordCoreData.trackerId,
                let date = recordCoreData.date
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        })
    }
    
    func makeRecord(for trackerId: UUID, date: Date) throws {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.trackerId = trackerId
        recordEntity.date = date
        
        try context.save()
    }
    
    func removeRecord(for trackerId: UUID, date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startDate as NSDate,
            endDate as NSDate
        )
        
        let records = try context.fetch(request)
        for record in records {
            context.delete(record)
        }
        
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCompletedTrackers()
        delegate?.trackerRecordStoreDidUpdate(self)
    }
}
