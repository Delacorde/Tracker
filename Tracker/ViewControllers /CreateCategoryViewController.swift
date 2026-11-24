
import UIKit

final class CreateCategoryViewController: UIViewController,UITextFieldDelegate {

    // MARK: - Properties

    var onCategoryCreated: (() -> Void)?

    private let categoryStore: TrackerCategoryStoreProtocol
    private let categoryToEdit: String?

    // MARK: - Initializer

    init(categoryStore: TrackerCategoryStoreProtocol, categoryToEdit: String? = nil) {
        self.categoryStore = categoryStore
        self.categoryToEdit = categoryToEdit
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
        label.text = categoryToEdit == nil
            ? NSLocalizedString("New Category", comment: "новая категория")
            : NSLocalizedString("Edit Category", comment: "редактирование категории")
        return label
    }()

    private lazy var textField: UITextField = {
        let text = UITextField()
        text.clearButtonMode = .whileEditing
        text.translatesAutoresizingMaskIntoConstraints = false
        text.layer.cornerRadius = 16
        text.placeholder = NSLocalizedString("Enter category name", comment: "название категории")
        
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
        button.backgroundColor = .categoryBUtton
        button.setTitle(NSLocalizedString("Done", comment: "done"), for: .normal)
        button.setTitleColor(Colors().categoryLabelColor, for: .normal)

        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        view.backgroundColor = Colors().viewBackground

        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )

        setUpViews()
        setUpConstraints()

        if let categoryToEdit {
            textField.text = categoryToEdit
            textFieldDidChange()
        }
    }

    // MARK: - Setup

    private func setUpViews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(completeButton)
        view.addSubview(nameErrorLabel)

        completeButton.addTarget(
            self,
            action: #selector(completeTapped),
            for: .touchUpInside
        )
    }
    private lazy var nameErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничени 38 символов"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            nameErrorLabel.topAnchor.constraint(
                equalTo: textField.bottomAnchor,
                constant: 4
            ),

            nameErrorLabel.leadingAnchor.constraint(
                equalTo: textField.leadingAnchor
            ),

            nameErrorLabel.trailingAnchor.constraint(
                equalTo: textField.trailingAnchor
            ),
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
        let text = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let isValid = !text.isEmpty && text.count <= 38

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

        do {
            if let categoryToEdit {
                try categoryStore.updateCategory(
                    oldTitle: categoryToEdit,
                    newTitle: text
                )
            } else {
                let newCategory = TrackerCategory(
                    title: text,
                    trackers: []
                )
                try categoryStore.makeCategory(from: newCategory)
            }
            
            onCategoryCreated?()
            dismiss(animated: true)
        } catch {
            print("Не удалось сохранить категорию: \(error)")
        }
        guard let text = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              text.count <= 38 else {
            return
        }
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(
            in: textRange,
            with: string
        )

        if updatedText.count > 38 {
            nameErrorLabel.isHidden = false
            return false
        }

        nameErrorLabel.isHidden = true
        return true
    }
}
