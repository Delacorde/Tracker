import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //MARK: label
        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topLabel)
        topLabel.text = "Трекеры"
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        NSLayoutConstraint.activate([
            topLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88),
            topLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 105),
            topLabel.widthAnchor.constraint(equalToConstant: 254),
            topLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
        
        //MARK: button plus
        let buttonPlus = UIButton()
        let buttonImagePlus = UIImage(resource: .buttonPlus)
        buttonPlus.setImage(buttonImagePlus, for: .normal)
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonPlus)
        NSLayoutConstraint.activate([
            buttonPlus.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            buttonPlus.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 1),
            buttonPlus.bottomAnchor.constraint(equalTo: topLabel.topAnchor, constant: 1),
        ])
        
        //MARK: Search field
        let searchField = UISearchTextField()
        let searchImage = UIImage(resource: .search)
        searchField.placeholder = "Поиск:"
        searchField.leftView = UIImageView(image: searchImage)
        searchField.leftViewMode = .always
        searchField.backgroundColor = .search
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 7),
            searchField.widthAnchor.constraint(equalToConstant: 343),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        //MARK: DatePicker
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru-RU")
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: buttonPlus.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 77)
        ])
        //MARK: image star
        let star = UIImage(resource: .logoStar)
        let imageStar = UIImageView(image: star)
        imageStar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageStar)
        NSLayoutConstraint.activate([
            imageStar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageStar.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        //MARK: center label, under image
        let centerLabel = UILabel()
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLabel)
        centerLabel.text = "Что будем отслеживать?"
        centerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        NSLayoutConstraint.activate([
            centerLabel.topAnchor.constraint(equalTo: imageStar.bottomAnchor, constant: 8),
            centerLabel.centerXAnchor.constraint(equalTo: imageStar.centerXAnchor)
        ])
    }
}

