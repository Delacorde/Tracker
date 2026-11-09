import UIKit

enum WeekDays: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString("Mon", comment: "mon")
        case .tuesday: return NSLocalizedString("Tue", comment: "tue")
        case .wednesday: return NSLocalizedString("Wed", comment: "wed")
        case .thursday: return NSLocalizedString("Thu", comment: "thu")
        case .friday: return NSLocalizedString("Fri", comment: "fri")
        case .saturday: return NSLocalizedString("Sut", comment: "sut")
        case .sunday: return NSLocalizedString("Sun", comment: "sun")
        }
    }
}
//MARK: Tracker
struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [WeekDays]?
}

//MARK: TrackerCategory
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

//MARK: TrackerRecord
struct TrackerRecord: Hashable{
    let trackerId: UUID
    let date: Date
}
extension WeekDays {
    static func decode(from string: String) -> [WeekDays] {
        let components = string.components(separatedBy: ",")
        return components.compactMap { component in
            guard let intValue = Int(component) else { return nil }
            return WeekDays(rawValue: intValue)
        }
    }
}
