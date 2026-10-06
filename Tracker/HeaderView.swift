import UIKit

final class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderView"
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 19, weight: .bold)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
