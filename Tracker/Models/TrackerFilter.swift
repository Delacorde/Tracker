
import Foundation

enum TrackerFilter {
    case all
    case today
    case completed
    case notCompleted

    static func isScheduled(_ tracker: Tracker, on date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let trackerWeekday = WeekDays(
            rawValue: weekday == 1 ? 7 : weekday - 1
        )

        guard let trackerWeekday else { return false }

        return tracker.schedule.contains(trackerWeekday)
    }

    func filtered(
        trackers: [Tracker],
        completedTrackers: [TrackerRecord],
        date: Date
    ) -> [Tracker] {

        let selectedDate = Calendar.current.startOfDay(for: date)

        switch self {
        case .all, .today:
            return trackers.filter {
                Self.isScheduled($0, on: selectedDate)
            }

        case .completed:
            return trackers.filter { tracker in
                completedTrackers.contains { record in
                    record.trackerId == tracker.id &&
                    Calendar.current.isDate(
                        record.date,
                        inSameDayAs: selectedDate
                    )
                }
            }

        case .notCompleted:
            return trackers.filter { tracker in
                Self.isScheduled(tracker, on: selectedDate) &&
                !completedTrackers.contains { record in
                    record.trackerId == tracker.id &&
                    Calendar.current.isDate(
                        record.date,
                        inSameDayAs: selectedDate
                    )
                }
            }
        }
    }
}
