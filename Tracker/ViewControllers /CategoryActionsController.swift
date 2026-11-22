import UIKit

final class CategoryActionsViewController: UIViewController {
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onCancel: (() -> Void)?

    private let categoryTitle: String

    init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemMaterial)
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors().viewBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = categoryTitle
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = Colors().headerColor
        return label
    }()

    private lazy var editButton: UIButton = makeButton(
        title: NSLocalizedString("Edit", comment: "Редактировать"),
        action: #selector(editTapped)
    )

    private lazy var deleteButton: UIButton = makeButton(
        title: NSLocalizedString("Delete", comment: "Удалить"),
        titleColor: .systemRed,
        action: #selector(deleteTapped)
    )

    private lazy var cancelButton: UIButton = makeButton(
        title: NSLocalizedString("Cancel", comment: "Отмена"),
        action: #selector(cancelTapped)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(blurView)
        view.addSubview(cardView)
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(editButton)
        cardView.addSubview(deleteButton)
        
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            editButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            editButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 52),

            deleteButton.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 52),
            deleteButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),

            cancelButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(cancelTapped)
        )
        blurView.addGestureRecognizer(tap)
    }

    private func makeButton(
        title: String,
        titleColor: UIColor = Colors().headerColor,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = Colors().viewBackground
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func editTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onEdit?()
        }
    }

    @objc private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDelete?()
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
}

