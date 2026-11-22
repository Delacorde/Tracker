
import UIKit

final class StatsViewController: UIViewController {

    // MARK: - Properties

    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    private var firstStatisticView = StatisticView()
    private var secondStatisticView = StatisticView()
    private var thirdStatisticView = StatisticView()
    private var fourthStatisticView = StatisticView()

    private var trackers: [Tracker] = []
    private var completedRecords: [TrackerRecord] = []

    // MARK: - UI Elements

    private lazy var statsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString(
            "statistics",
            comment: "Заголовок экрана"
        )
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .forText)
        return label
    }()

    private lazy var analyzeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = NSLocalizedString(
            "analyzeEmpty",
            comment: "Пустая статистика"
        )
        label.textColor = UIColor(resource: .forText)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var cryEmoji: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cryinEmo")
        imageView.contentMode = .scaleAspectFit
                return imageView
            }()

    private lazy var statisticStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Initializer

    init(
        trackerStore: TrackerStore,
        recordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(resource: .backgroundDay)

        setUpView()
        setUpStackView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadStatisticsData()
        updateStatistics()
        updatePlaceholder()
    }

    // MARK: - Statistics

    private func loadStatisticsData() {
        trackers = trackerStore.trackers
        completedRecords = Array(recordStore.completedTrackers)
    }

    private func updateStatistics() {

        thirdStatisticView.configure(
            number: String(completedRecords.count),
            description: NSLocalizedString(
                "trackersCompleted",
                comment: "Трекеров завершено"
            )
        )

        firstStatisticView.configure(
            number: String(calculateBestPeriod()),
            description: NSLocalizedString(
                "bestPeriod",
                comment: "Лучший период"
            )
        )

        secondStatisticView.configure(
            number: String(calculateBestDay()),
            description: NSLocalizedString(
                "perfectDays",
                comment: "Идеальные дни"
            )
        )

        fourthStatisticView.configure(
            number: String(format: "%.1f", averageValue()),
            description: NSLocalizedString(
                "averageValue",
                comment: "Среднее значение"
            )
        )
    }

    // MARK: - Average Value

    private func averageValue() -> Double {

        let calendar = Calendar.current

        guard let firstRecordDate = completedRecords
            .map({ $0.date })
            .min() else {
            return 0
        }

        let startDate = calendar.startOfDay(for: firstRecordDate)
        let finishDate = calendar.startOfDay(for: Date())

        let diffInDays = calendar.dateComponents(
            [.day],
            from: startDate,
            to: finishDate
        ).day

        let daysCount = (diffInDays ?? 0) + 1

        return Double(completedRecords.count) /
            Double(daysCount)
    }

    // MARK: - Perfect Days

    private func calculateBestDay() -> Int {

        let calendar = Calendar.current

        guard let firstRecordDate = completedRecords
            .map({ $0.date })
            .min() else {
            return 0
        }

        let startDate = calendar.startOfDay(for: firstRecordDate)
        let finishDate = calendar.startOfDay(for: Date())

        var currentDay = startDate
        var perfectDaysCount = 0

        while currentDay <= finishDate {

            let weekdayNumber = calendar.component(
                .weekday,
                from: currentDay
            )

            guard let weekDay = WeekDays(
                rawValue: weekdayNumber == 1
                    ? 7
                    : weekdayNumber - 1
            ) else {
                break
            }

            let scheduledTrackers = trackers.filter {
                $0.schedule.contains(weekDay)
            }

            let isPerfectDay = !scheduledTrackers.isEmpty &&
                scheduledTrackers.allSatisfy { tracker in

                    completedRecords.contains { record in
                        record.trackerId == tracker.id &&
                        calendar.isDate(
                            record.date,
                            inSameDayAs: currentDay
                        )
                    }
                }

            if isPerfectDay {
                perfectDaysCount += 1
            }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDay
            ) else {
                break
            }

            currentDay = nextDate
        }

        return perfectDaysCount
    }

    // MARK: - Best Period

    private func calculateBestPeriod() -> Int {

        let calendar = Calendar.current

        guard let firstRecordDate = completedRecords
            .map({ $0.date })
            .min() else {
            return 0
        }

        let startDate = calendar.startOfDay(for: firstRecordDate)
        let finishDate = calendar.startOfDay(for: Date())

        var currentDay = startDate
        var currentStreak = 0
        var bestStreak = 0

        while currentDay <= finishDate {

            let weekdayNumber = calendar.component(
                .weekday,
                from: currentDay
            )

            guard let weekDay = WeekDays(
                rawValue: weekdayNumber == 1
                    ? 7
                    : weekdayNumber - 1
            ) else {
                break
            }

            let scheduledTrackers = trackers.filter {
                $0.schedule.contains(weekDay)
            }

            let isPerfectDay = !scheduledTrackers.isEmpty &&
                scheduledTrackers.allSatisfy { tracker in

                    completedRecords.contains { record in
                        record.trackerId == tracker.id &&
                        calendar.isDate(
                            record.date,
                            inSameDayAs: currentDay
                        )
                    }
                }

            if isPerfectDay {
                currentStreak += 1
            } else {
                currentStreak = 0
            }

            bestStreak = max(bestStreak, currentStreak)

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDay
            ) else {
                break
            }

            currentDay = nextDate
        }

        return bestStreak
    }

    // MARK: - Setup Views

    private func setUpView() {
        view.addSubview(statsLabel)
        view.addSubview(cryEmoji)
        view.addSubview(analyzeLabel)
    }

    private func setUpStackView() {

        view.addSubview(statisticStackView)

        statisticStackView.addArrangedSubview(firstStatisticView)
        statisticStackView.addArrangedSubview(secondStatisticView)
        statisticStackView.addArrangedSubview(thirdStatisticView)
        statisticStackView.addArrangedSubview(fourthStatisticView)
    }

    // MARK: - Constraints

    private func setUpConstraints() {

        NSLayoutConstraint.activate([

            statsLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            ),

            statsLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),

            statisticStackView.topAnchor.constraint(
                equalTo: statsLabel.bottomAnchor,
                constant: 77
            ),

            statisticStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            statisticStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),

            statisticStackView.heightAnchor.constraint(
                equalToConstant: 396
            ),

            cryEmoji.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            cryEmoji.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

            cryEmoji.widthAnchor.constraint(
                equalToConstant: 80
            ),

            cryEmoji.heightAnchor.constraint(
                equalToConstant: 80
            ),

            analyzeLabel.topAnchor.constraint(
                equalTo: cryEmoji.bottomAnchor,
                constant: 8
            ),

            analyzeLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])

        firstStatisticView.heightAnchor.constraint(
            equalToConstant: 90
        ).isActive = true
    }

    // MARK: - Placeholder

    private func updatePlaceholder() {

        let noCompletedTrackers = completedRecords.isEmpty

        cryEmoji.isHidden = !noCompletedTrackers
        analyzeLabel.isHidden = !noCompletedTrackers
        statisticStackView.isHidden = noCompletedTrackers
    }
}
