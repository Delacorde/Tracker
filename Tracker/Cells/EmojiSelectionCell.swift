import UIKit

final class EmojiSelectionCell: UICollectionViewCell {
    
    static let identifier = "EmojiSelectionCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(resource: .lightGray)
        view.layer.cornerRadius = 16
        view.alpha = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(emojiLabel)
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            selectionBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            selectionBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            selectionBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool){
        emojiLabel.text = emoji
        selectionBackgroundView.alpha = isSelected ? 1.0 : 0.0
    }
}
