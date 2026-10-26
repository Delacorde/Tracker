import UIKit

final class ColorSelectionCell: UICollectionViewCell {
    static let identifier = "ColorSelectionCell"
    
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 8
        view.isHidden = true
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
       
        contentView.addSubview(borderView)
        contentView.addSubview(colorView)
        
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
           
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
           
            borderView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            borderView.isHidden = false
        } else {
            borderView.isHidden = true
        }
    }
}
