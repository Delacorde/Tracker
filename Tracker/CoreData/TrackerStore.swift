import CoreData
import UIKit
protocol TrackerStoreProtocol {
    var trackers: [Tracker] {get}
    func makeTracker(from tracker: Tracker, in category: TrackerCategoryCoreData) throws
}
final class TrackerStore: NSObject, TrackerStoreProtocol{
    private let context: NSManagedObjectContext
    
    var trackers: [Tracker] {
        return []
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    // конвертация из кор даты в структуру трекера
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji
        else {
            throw NSError(domain: "TrackerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode Tracker"])
        }
        
        let schedule = trackerCoreData.schedule as? [WeekDays]
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    //создание и сохранение новоего трекера
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
