
import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

@MainActor
final class TrackerViewControllerSnapshotTests: XCTestCase {

    func testViewController() throws {

        let persistenceContainer = PersistenceContainer(inMemory: true)

        let trackerStore = persistenceContainer.trackerStore
        let categoryStore = persistenceContainer.categoryStore
        let recordStore = persistenceContainer.recordStore

        let tracker = Tracker(
            id: UUID(),
            name: "посмотреть фильм",
            color: "ColorSection1",
            emoji: "✌🏾",
            schedule: WeekDays.allCases,
            isPinned: false
        )

        try trackerStore.makeTracker(
            from: tracker,
            in: "Полезные привычки"
        )

        let vc = TrackerViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore,
            persistenceContainer: persistenceContainer
        )

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        vc.loadViewIfNeeded()
        window.layoutIfNeeded()
        vc.view.layoutIfNeeded()

        assertSnapshot(
            matching: vc.view,
            as: .image
        )

        window.isHidden = true
        window.rootViewController = nil
    }
}
