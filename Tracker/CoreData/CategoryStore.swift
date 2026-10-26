import CoreData
import UIKit

protocol CategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func makeCategory(from category: TrackerCategory) throws
    func fetchCategories() throws -> [TrackerCategoryCoreData]
}

final class CategoryStore: NSObject, CategoryStoreProtocol {
    private let context: NSManagedObjectContext
    
    var categories: [TrackerCategory] {
        return []
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
    
    func fetchCategories() throws -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request)
    }
}
