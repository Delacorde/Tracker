import UIKit

enum WeekDays: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Cб"
        case .sunday: return "Вс"
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
