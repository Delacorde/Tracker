import UIKit

final class TrackerViewController: UIViewController, HabitViewDelegate {
    // MARK: - Properties
    private var contextMenuIndexPath: IndexPath?
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let geometryParams = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let persistenceContainer: PersistenceContainer
    private var selectedFilter: TrackerFilter = .all
    private var visibleCategories: [TrackerCategory] = []
    private var screenBlurView: UIVisualEffectView?
    private var selectedCellSnapshot: UIView?
    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        persistenceContainer: PersistenceContainer
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.persistenceContainer = persistenceContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Filter", comment: "filter button"), for: .normal)
        button.backgroundColor = UIColor.filter
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(resource: .plusButton)
                .withRenderingMode(.alwaysTemplate)

        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        
        return button
    }()
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Trackers", comment: "trackers")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = Colors().headerColor
        return label
    }()
    private lazy var searchInputTextField: UISearchTextField = {
        let textField = UISearchTextField()
        let magnifyingGlassIcon = UIImageView(image: UIImage(resource: .searchIcon))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = magnifyingGlassIcon
        textField.leftViewMode = .always
        textField.backgroundColor = Colors().textFieldBackground
        textField.placeholder = NSLocalizedString("Search", comment: "search")
        textField.textColor = Colors().textField
        return textField
    }()
    private lazy var dateSelectionPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.backgroundColor = UIColor.date
        picker.layer.cornerRadius = 12
        picker.layer.masksToBounds = true
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale.current
        picker.overrideUserInterfaceStyle = .light

        return picker
    }()
    

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .logoStar))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var emptyStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("What do Track?", comment: "что будем отслеживать ")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    @objc func switchToFilter() {
        let filterVC = FilterViewController(selectedFilter: selectedFilter)
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .pageSheet
        present(filterVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors().viewBackground
        filterButton.addTarget(self, action: #selector(switchToFilter), for: .touchUpInside)
        dateSelectionPicker.addTarget(self, action: #selector(handleDatePickerChange(_:)), for: .valueChanged)
        collectionView.backgroundColor = Colors().viewBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        completedTrackers = Array(recordStore.completedTrackers)
        applyFilter()
        searchInputTextField.addTarget(
            self,
            action: #selector(searchTextDidChange),
            for: .editingChanged
        )
        
        
        checkEmptyState()
        
        configureSubviews()
        configureConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
    }
    @objc private func searchTextDidChange() {
        applyFilter()
    }
    // hide keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    private func configureSubviews() {
        view.addSubview(headerTitleLabel)
        view.addSubview(addButton)
        view.addSubview(searchInputTextField)
        view.addSubview(dateSelectionPicker)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateDescriptionLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
   
    private func applyFilter() {
        let searchText = searchInputTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let allCategories = categoryStore.categories

        let allTrackers = allCategories.flatMap { $0.trackers }
        let selectedDate = Calendar.current.startOfDay(
            for: dateSelectionPicker.date
        )

        let hasTrackersForSelectedDate = allTrackers.contains {
            TrackerFilter.isScheduled($0, on: selectedDate)
        }

        filterButton.isHidden = !hasTrackersForSelectedDate

        let pinnedTrackers = allTrackers.filter { $0.isPinned }

        let pinnedCategory = TrackerCategory(
            title: "Закреплённые",
            trackers: pinnedTrackers
        )


        var regularCategories = allCategories.map { category in
            let unpinnedTrackers = category.trackers.filter {
                !$0.isPinned
            }

            return TrackerCategory(
                title: category.title,
                trackers: unpinnedTrackers
            )
        }

        if !pinnedTrackers.isEmpty {
            regularCategories.insert(pinnedCategory, at: 0)
        }
        categories = regularCategories.compactMap { category in

            let filteredTrackers = selectedFilter.filtered(
                trackers: category.trackers,
                completedTrackers: completedTrackers,
                date: selectedDate
            )

            let searchedTrackers = filteredTrackers.filter { tracker in
                searchText.isEmpty ||
                tracker.name.localizedCaseInsensitiveContains(searchText)
            }

            guard !searchedTrackers.isEmpty else {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: searchedTrackers
            )
        }

        collectionView.reloadData()
        checkEmptyState()
    }


    private func configureConstraints() {
        NSLayoutConstraint.activate([
            // Header Title
            headerTitleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            headerTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // Add Button
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            
            addButton.heightAnchor.constraint(equalToConstant: 42),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            // searchField
            searchInputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchInputTextField.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 7),
            searchInputTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchInputTextField.heightAnchor.constraint(equalToConstant: 36),
            //date picker
            dateSelectionPicker.topAnchor.constraint( equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1 ), dateSelectionPicker.trailingAnchor.constraint( equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16 ),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateDescriptionLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateDescriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            
            collectionView.topAnchor.constraint(equalTo: searchInputTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //filterButton
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filterButton.heightAnchor.constraint(equalToConstant : 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    private func checkEmptyState() {
        let hasNoData = categories.isEmpty || categories.allSatisfy { $0.trackers.isEmpty }
        
        emptyStateImageView.isHidden = !hasNoData
        emptyStateDescriptionLabel.isHidden = !hasNoData
        collectionView.isHidden = hasNoData
    }
    private func isTrackerDoneOnSelectedDate(id: UUID) -> Bool {
        let targetDate = Calendar.current.startOfDay(for: dateSelectionPicker.date)
        return completedTrackers.contains { record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: targetDate)
        }
    }
    
    func didCreateTracker(_ tracker: Tracker, category: String) {
        do {
            try trackerStore.makeTracker(
                from: tracker,
                in: category
            )
            categories = categoryStore.categories

            completedTrackers = Array(recordStore.completedTrackers)

            checkEmptyState()
            collectionView.reloadData()

        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }

    
    @objc private func handleDatePickerChange(_ sender: UIDatePicker) {
        applyFilter()
    }

    @objc private func addButtonTapped() {
        let habitCreationVC = HabitViewController(persistenceContainer: persistenceContainer)
        habitCreationVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: habitCreationVC)
        present(navigationVC, animated: true)
    }
}
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let item = categories[indexPath.section].trackers[indexPath.row]
        let isDone = isTrackerDoneOnSelectedDate(id: item.id)
        let completedDays = completedTrackers.filter { $0.trackerId == item.id }.count
        cell.configure(isCompleted: isDone, completedDays: completedDays, tracker: item)
        return cell
    }
}
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        contextMenuIndexPath = indexPath
        let tracker = categories[indexPath.section].trackers[indexPath.item]

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in

            guard let self = self else {
                return UIMenu()
            }

            // Закрепление
            let pinAction = UIAction(
                title: tracker.isPinned ? "Открепить" : "Закрепить",
                image: UIImage(systemName: tracker.isPinned ? "pin.slash" : "pin")
            ) { [weak self] _ in

                guard let self = self else { return }

                do {
                    try self.trackerStore.updatePinStatus(
                        for: tracker.id,
                        isPinned: !tracker.isPinned
                    )
                    self.applyFilter()
                } catch {
                    print("Ошибка изменения закрепления: \(error)")
                }
            }

            // Редактирование
            let editAction = UIAction(
                title: NSLocalizedString("edit", comment: "edit"),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in

                guard let self = self else { return }

                let editVC = HabitViewController(
                    persistenceContainer: self.persistenceContainer
                )

                let completedDays = self.completedTrackers.filter {
                    $0.trackerId == tracker.id
                }.count

                let categoryTitle = self.categoryStore.categories.first {
                    $0.trackers.contains(where: { $0.id == tracker.id })
                }?.title ?? ""

                editVC.configureEditing(
                    tracker: tracker,
                    categoryTitle: categoryTitle,
                    completedDaysCount: completedDays
                )

                editVC.onUpdateTracker = { [weak self] updatedTracker, categoryTitle in
                    guard let self = self else { return false }

                    do {
                        try self.trackerStore.updateTracker(
                            updatedTracker,
                            withCategory: categoryTitle
                        )
                        self.applyFilter()
                        return true
                    } catch {
                        print("Ошибка редактирования трекера: \(error)")
                        return false
                    }
                }

                let navigationController = UINavigationController(
                    rootViewController: editVC
                )

                self.present(navigationController, animated: true)
            }

            // Удаление
            let deleteAction = UIAction(
                title: NSLocalizedString("delete", comment: "delete"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                let alert = UIAlertController(
                    title: NSLocalizedString("deleteTracker", comment: "delTracker"),
                    message: "История выполнения этого трекера тоже будет удалена.",
                    preferredStyle: .actionSheet
                )

                let confirmAction = UIAlertAction(
                    title: "Удалить",
                    style: .destructive
                ) { [weak self] _ in

                    guard let self = self else { return }

                    do {
                        try self.recordStore.removeAllRecords(
                            for: tracker.id
                        )

                        try self.trackerStore.deleteTracker(
                            with: tracker.id
                        )

                        self.completedTrackers = Array(
                            self.recordStore.completedTrackers
                        )

                        self.applyFilter()

                    } catch {
                        print("Ошибка удаления трекера: \(error)")
                    }
                }

                alert.addAction(confirmAction)
                alert.addAction(
                    UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .cancel)
                )

                self.present(alert, animated: true)
            }

            return UIMenu(
                children: [pinAction, editAction, deleteAction]
            )
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - geometryParams.paddingWidth
        let itemWidth = availableWidth / CGFloat(geometryParams.cellCount)
        return CGSize(width: itemWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        headerView.titleLabel.text = categories[indexPath.section].title
        return headerView
    }
}
extension TrackerViewController: TrackerCellDelegate {
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let selectedTracker = categories[indexPath.section].trackers[indexPath.row]
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let chosenDate = calendar.startOfDay(for: dateSelectionPicker.date)
        
        guard chosenDate <= today else {
            return
        }
        
        if completedTrackers.contains(where: {
            $0.trackerId == selectedTracker.id &&
            calendar.isDate($0.date, inSameDayAs: chosenDate)
        }) {
            do {
                try recordStore.removeRecord(
                    for: selectedTracker.id,
                    date: chosenDate
                )
            } catch {
                print("Ошибка удаления записи: \(error)")
            }
        } else {
            do {
                try recordStore.makeRecord(
                    for: selectedTracker.id,
                    date: chosenDate
                )
            } catch {
                print("Ошибка сохранения записи: \(error)")
            }
        }
        
        completedTrackers = Array(recordStore.completedTrackers)
        applyFilter()
    }
}

extension TrackerViewController: FilterViewControllerDelegate {
    func chosenFilter(filter: TrackerFilter) {
        selectedFilter = filter
        if filter == .today {
            dateSelectionPicker.setDate(Date(), animated: false)
        }
        applyFilter()
    }
}

