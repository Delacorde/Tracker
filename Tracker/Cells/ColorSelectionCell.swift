import UIKit

final class ColorSelectionCell: UICollectionViewCell{
    static let identifier = "ColorSelectionCell"
    let colorView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    private func setupView(){
        contentView.addSubview(colorView)
        contentView.backgroundColor = .clear
    }
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    func configure(color: UIColor, isSelected: Bool){
        colorView.backgroundColor = color
        
        if isSelected {
            colorView.layer.borderWidth = 2
            colorView.layer.borderColor = UIColor.black.cgColor
        } else {
            colorView.layer.borderWidth = 0
        }
    }
}

