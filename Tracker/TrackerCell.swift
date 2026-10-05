import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapPlus(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor(resource: .greenSection18)
        view.layer.borderColor = UIColor(resource: .borderCard).cgColor
        return view
    }()
    
    private var emojiContainerView: UIView = {
        let emoji = UIView()
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emoji.backgroundColor = UIColor(resource: .emoji)
        emoji.layer.cornerRadius = 12
        return emoji
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "😘"
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Поливать растения"
        return label
    }()
    
    private let countLabel: UILabel = {
        let count = UILabel()
        count.font = .systemFont(ofSize: 12, weight: .medium)
        count.textColor = .label
        count.translatesAutoresizingMaskIntoConstraints = false
        count.text = "0 дней"
        return count
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(resource: .greenSection18)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = .white
        let plus = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let image = UIImage(systemName: AppIcons.SystemSymbols.addIcon, withConfiguration: plus
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            //CardView
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            //EmojiContainerView
            emojiContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),
            //EmojiLabel
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            //TitleLabel
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            //CountLabel
            countLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            countLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            //PlusButton
            plusButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    private func setupView() {
        contentView.addSubview(cardView)
        contentView.addSubview(plusButton)
        contentView.addSubview(countLabel)
        cardView.addSubview(emojiContainerView)
        cardView.addSubview(titleLabel)
        emojiContainerView.addSubview(emojiLabel)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        
    }
    func configure(isCompleted: Bool, completedDays: Int, tracker: Tracker){
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        countLabel.text = completedDays.formatDaysCount()
        let image = isCompleted ? AppIcons.SystemSymbols.checkmarkIcon : AppIcons.SystemSymbols.addIcon
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let imageName = UIImage(systemName: image, withConfiguration: config)
        plusButton.setImage(UIImage(systemName: image), for: .normal)
        plusButton.alpha = isCompleted ? 0.5 : 1.0
    }
    
    @objc private func didTapPlusButton() {
        delegate?.trackerCellDidTapPlus(self)
    }
}

