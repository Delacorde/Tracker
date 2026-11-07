
import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    
    var onCategorySelected: ((String) -> Void)?
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private let viewModel: CategoriesViewModel
    
    // MARK: - Initializer
    
    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        self.viewModel = CategoriesViewModel(categoryStore: categoryStore)
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
        label.text = "Привычки и события можно \nобъединить по смыслу"
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
        label.text = "Категория"
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(resource: .blackDay)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(resource: .whiteDay), for: .normal)
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
        
        view.backgroundColor = UIColor(resource: .whiteDay)
        
        tableView.register(
            TrackerCategoryCell.self,
            forCellReuseIdentifier: TrackerCategoryCell.identifier
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        
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
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -20),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor,constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            //MARK: TableView
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            //MARK : Button
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -16),
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
    
    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
    }
}
