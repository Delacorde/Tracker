
import UIKit

final class CreateCategoryViewController: UIViewController {

    // MARK: - Properties

    var onCategoryCreated: (() -> Void)?

    private let categoryStore: TrackerCategoryStoreProtocol

    // MARK: - Initializer

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(resource: .blackDay)
        label.textAlignment = .center
        label.text = "Новая категория"
        return label
    }()

    private lazy var textField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.layer.cornerRadius = 16
        text.placeholder = "Введите название категории"

        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )

        text.leftView = paddingView
        text.leftViewMode = .always
        text.backgroundColor = UIColor(resource: .backgroundDay)
        return text
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .gray
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(resource: .whiteDay), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(resource: .whiteDay)

        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )

        setUpViews()
        setUpConstraints()
    }

    // MARK: - Setup

    private func setUpViews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(completeButton)

        completeButton.addTarget(
            self,
            action: #selector(completeTapped),
            for: .touchUpInside
        )
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),

            textField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            textField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 38
            ),
            textField.heightAnchor.constraint(equalToConstant: 75),

            completeButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            completeButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            completeButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions

    @objc private func textFieldDidChange() {
        let text = textField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? ""

        let isValid = !text.isEmpty && text.count < 38

        completeButton.isEnabled = isValid
        completeButton.backgroundColor = isValid
            ? UIColor(resource: .blackDay)
            : .gray
    }

    @objc private func completeTapped() {
        guard let text = textField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !text.isEmpty else {
            return
        }

        let newCategory = TrackerCategory(
            title: text,
            trackers: []
        )

        do {
            try categoryStore.makeCategory(from: newCategory)
            onCategoryCreated?()
            dismiss(animated: true)
        } catch {
            print("Не удалось сохранить категорию: \(error)")
        }
    }
}
