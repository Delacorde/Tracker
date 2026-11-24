
import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    
    var onCategorySelected: ((String) -> Void)?
    var onCategoryDeleted: ((String) -> Void)?
    private let categoryStore: TrackerCategoryStoreProtocol
    private let viewModel: CategoriesViewModel
    
    // MARK: - Initializer
    
    init(
        categoryStore: TrackerCategoryStoreProtocol,
        selectedCategory: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.viewModel = CategoriesViewModel(
            categoryStore: categoryStore,
            selectedCategory: selectedCategory
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var emptyStateImageView: UIImageView = {
        let image = UIImageView(image: UIImage(resource: .logoStar))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("habits_events_description", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(resource: .blackDay)
        label.textAlignment = .center
        label.text = NSLocalizedString("Category", comment: "категория")
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = Colors().headerColor
        button.setTitle(NSLocalizedString("Add Category", comment: "Кнопка добавления категории"), for: .normal)
        button.setTitleColor(Colors().viewBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        table.backgroundColor = .clear
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors().viewBackground
        
        tableView.register(
            TrackerCategoryCell.self,
            forCellReuseIdentifier: TrackerCategoryCell.identifier
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleCategoryLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPress)
        
        setUpViews()
        setUpConstraints()
        bindViewModel()
        
        viewModel.loadCategories()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.categoryArrayDidChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelected?(title)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateUI() {
        let isEmpty = viewModel.numberOfCategories() == 0
        
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setUpViews() {
        view.addSubview(titleLabel)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        addButton.addTarget(
            self,
            action: #selector(addCategoryTapped),
            for: .touchUpInside
        )
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // MARK: TableView
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // MARK: Button
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        let createVC = CreateCategoryViewController(
            categoryStore: categoryStore
        )
        
        createVC.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        
        present(createVC, animated: true)
    }

    @objc private func handleCategoryLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: location),
              viewModel.categories.indices.contains(indexPath.row) else {
            return
        }

        let category = viewModel.categories[indexPath.row]
        let actionsVC = CategoryActionsViewController(categoryTitle: category.title)
        
        actionsVC.onEdit = { [weak self] in
            self?.showEditCategory(for: category.title)
        }
        
        actionsVC.onDelete = { [weak self] in
            self?.confirmDeleteCategory(title: category.title)
        }
        
        present(actionsVC, animated: true)
    }

    private func showEditCategory(for title: String) {
        let editVC = CreateCategoryViewController(
            categoryStore: categoryStore,
            categoryToEdit: title
        )
        
        editVC.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        
        present(editVC, animated: true)
    }

    private func confirmDeleteCategory(title: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Delete category?", comment: "Подтверждение удаления категории"),
            message: NSLocalizedString("All trackers in this category will be deleted.", comment: "Все трекеры категории будут удалены"),
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Delete", comment: "Удалить"),
            style: .destructive
        ) { [weak self] _ in
            do {
                try self?.categoryStore.deleteCategory(with: title)
                self?.viewModel.loadCategories()
            } catch {
                print("Не удалось удалить категорию: \(error)")
            }
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Отмена"),
            style: .cancel
        ) { [weak self] _ in
            self?.viewModel.loadCategories()
        })

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TrackerCategoryCell.identifier,
                for: indexPath
            ) as? TrackerCategoryCell,
            let cellViewModel = viewModel.cellViewModel(at: indexPath)
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    
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
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
    }
}
