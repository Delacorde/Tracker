import CoreData
import UIKit

protocol RecordStoreProtocol {
    func makeRecord(for trackerId: UUID, date: Date) throws
    func fetchRecords(for trackerId: UUID) throws -> [TrackerRecordCoreData]
}

final class RecordStore: NSObject, RecordStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func makeRecord(for trackerId: UUID, date: Date) throws {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.date = date
        recordEntity.trackerId = trackerId
        
        try context.save()
    }
    
    func fetchRecords(for trackerId: UUID) throws -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        return try context.fetch(request)
    }
}
