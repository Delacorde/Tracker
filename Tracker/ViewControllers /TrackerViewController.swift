import UIKit

final class TrackerViewController: UIViewController, HabitViewDelegate {
    // MARK: - Properties
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let geometryParams = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .plusButton), for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        
        return button
    }()
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        return label
    }()
    private lazy var searchInputTextField: UISearchTextField = {
        let textField = UISearchTextField()
        let magnifyingGlassIcon = UIImageView(image: UIImage(resource: .searchIcon))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = magnifyingGlassIcon
        textField.leftViewMode = .always
        textField.backgroundColor = .color
        textField.text = "Поиск"
        return textField
    }()
    private lazy var dateSelectionPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
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
            label.text = "Что будем отслеживать?"
            label.font = .systemFont(ofSize: 12, weight: .medium)
            return label
        }()
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            dateSelectionPicker.addTarget(self, action: #selector(handleDatePickerChange(_:)), for: .valueChanged)
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
            collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            
            let sampleTracker = Tracker(id: UUID(), name: "first tracker", color: "ColorSection1", emoji: "🫅🏼", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
            categories = [TrackerCategory(title: "Домашний уют", trackers: [sampleTracker])]
            
            collectionView.reloadData()
            checkEmptyState()
            
            configureSubviews()
            configureConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)


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
            
            addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
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
                
                collectionView.topAnchor.constraint(equalTo: searchInputTextField.bottomAnchor, constant: 10),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    func didCreateTracker(_ tracker: Tracker) {
            if let firstCategory = categories.first {
                var updatedTrackersList = firstCategory.trackers
                updatedTrackersList.append(tracker)
                categories[0] = TrackerCategory(title: firstCategory.title, trackers: updatedTrackersList)
            } else {
                let defaultCategory = TrackerCategory(title: "Новый день", trackers: [tracker])
                categories.append(defaultCategory)
            }
            
            checkEmptyState()
            collectionView.reloadData()
        }
    @objc private func handleDatePickerChange(_ sender: UIDatePicker) {
            let selectedDate = sender.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: selectedDate)
            print("Выбранная дата:\(dateString)")
            collectionView.reloadData()
        }
    @objc private func addButtonTapped() {
            let habitCreationVC = HabitViewController()
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - geometryParams.paddingWidth
        let itemWidth = availableWidth / CGFloat(geometryParams.cellCount)
        return CGSize(width: itemWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return geometryParams.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        headerView.titleLabel.text = "Домашний уют"
        return headerView
    }
}
extension TrackerViewController: TrackerCellDelegate {
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let selectedTracker = categories[indexPath.section].trackers[indexPath.row]
        print("получаем трекер")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let chosenDate = calendar.startOfDay(for: dateSelectionPicker.date)
        
        guard chosenDate <= today else { return }
        
        if let existingIndex = completedTrackers.firstIndex(where: { $0.trackerId == selectedTracker.id && calendar.isDate($0.date, inSameDayAs: chosenDate) }) {
            completedTrackers.remove(at: existingIndex)
            print("удаляем рекорд")
        } else {
            let record = TrackerRecord(trackerId: selectedTracker.id, date: chosenDate)
            completedTrackers.append(record)
            print("добавляем новый рекорд")
        }
        
        collectionView.reloadItems(at: [indexPath])
        print("перезагружаем ячейку")
    }
}
