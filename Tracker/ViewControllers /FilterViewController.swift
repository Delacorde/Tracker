
import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func chosenFilter(filter: TrackerFilter)
}

final class FilterViewController: UIViewController {

    // MARK: - Properties

    private static let filterOptions = [
        NSLocalizedString("allTrackers", comment: "Все трекеры"),
        NSLocalizedString("dailyTrackers", comment: "Трекеры на сегодня"),
        NSLocalizedString("completedTrackers", comment: "Завершенные"),
        NSLocalizedString("notCompletedtrackers", comment: "Не завершенные")
    ]

    private let filters: [TrackerFilter] = [
        .all,
        .today,
        .completed,
        .notCompleted
    ]

    private let selectedFilter: TrackerFilter

    weak var delegate: FilterViewControllerDelegate?

    init(selectedFilter: TrackerFilter = .all) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString(
            "Filter",
            comment: "Фильтр лейбл"
        )
        label.textColor = Colors().headerColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        return table
    }()

    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors().viewBackground

        tableView.register(
            FilterCell.self,
            forCellReuseIdentifier: FilterCell.identifier
        )

        tableView.dataSource = self
        tableView.delegate = self

        setUpView()
        setUpConstraints()
    }

    // MARK: - Private Methods

    private func setUpView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([

            // TitleLabel
            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 31
            ),

            // TableView
            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 31
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),

            tableView.heightAnchor.constraint(
                equalToConstant: 300
            )
        ])
    }

    private var selectedRow: Int {
        filters.firstIndex { filter in
            switch (filter, selectedFilter) {
            case (.all, .all),
                 (.today, .today),
                 (.completed, .completed),
                 (.notCompleted, .notCompleted):
                return true
            default:
                return false
            }
        } ?? 0
    }
}

// MARK: - DataSource

extension FilterViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        filters.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.identifier
        ) as? FilterCell else {
            return UITableViewCell()
        }

        cell.textLabel?.text = Self.filterOptions[indexPath.row]
        cell.textLabel?.textColor = UIColor(resource: .forText)
        cell.textLabel?.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )
        cell.textLabel?.textAlignment = .left

        cell.tintColor = .systemBlue
        cell.accessoryType = indexPath.row == selectedRow
            ? .checkmark
            : .none

        return cell
    }
}

// MARK: - Delegate

extension FilterViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        UIView()
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let filter = filters[indexPath.row]

        delegate?.chosenFilter(filter: filter)

        tableView.reloadData()
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        dismiss(animated: true)
    }
}
