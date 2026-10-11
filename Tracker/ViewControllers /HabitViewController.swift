import UIKit

protocol HabitViewDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class HabitViewController: UIViewController, ScheduleViewControllerDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let availableEmojis: [String] = ["🫩","🫅🏻","🧠","🤯","❤️","💁🏼","😇","🙂","🤓","🤩","😟","😩","😫","😡","😳","🫠","🫨", "✌🏾"]
    let availableColors: [ColorOption] = [
        ColorOption(color: .colorSection1, name: "ColorSection1"),
        ColorOption(color: .colorSection2, name: "ColorSection2"),
        ColorOption(color: .colorSection3, name: "ColorSection3"),
        ColorOption(color: .colorSection4, name: "ColorSection4"),
        ColorOption(color: .colorSection5, name: "ColorSection5"),
        ColorOption(color: .colorSection6, name: "ColorSection6"),
        ColorOption(color: .colorSection7, name: "ColorSection7"),
        ColorOption(color: .colorSection8, name: "ColorSection8"),
        ColorOption(color: .colorSection9, name: "ColorSection9"),
        ColorOption(color: .colorSection10, name: "ColorSection10"),
        ColorOption(color: .colorSection11, name: "ColorSection11"),
        ColorOption(color: .colorSection12, name: "ColorSection12"),
        ColorOption(color: .colorSection13, name: "ColorSection13"),
        ColorOption(color: .colorSection14, name: "ColorSection14"),
        ColorOption(color: .colorSection15, name: "ColorSection15"),
        ColorOption(color: .colorSection16, name: "ColorSection16"),
        ColorOption(color: .colorSection17, name: "ColorSection17"),
        ColorOption(color: .colorSection18, name: "ColorSection18")
    ]

    var selectedColorOption: ColorOption? = nil
    var selectedEmoji: String? = nil
    
    private var selectedDays:[WeekDays] = []
    private var scheduleSubtitle: String?
    weak var delegate: HabitViewDelegate?
    private let options = ["Категория", "Расписание"]
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.register(ColorSelectionCell.self, forCellWithReuseIdentifier: ColorSelectionCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView .register(EmojiSelectionCell.self, forCellWithReuseIdentifier: EmojiSelectionCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    // dataSource funcs
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        if collectionView == emojiCollectionView {
                headerView.titleLabel.text = "Emoji"
            } else {
                headerView.titleLabel.text = "Цвет"
            }
            return headerView
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return availableEmojis.count
        } else {
            return availableColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiSelectionCell.identifier, for: indexPath) as? EmojiSelectionCell else {
                return UICollectionViewCell()
            }
            let emoji = availableEmojis[indexPath.item]
            cell.configure(with: emoji, isSelected: (selectedEmoji == emoji))
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorSelectionCell.identifier, for: indexPath) as? ColorSelectionCell else {
                return UICollectionViewCell()
            }
            let colorOption = availableColors[indexPath.item]
                cell.configure(color: colorOption.color, isSelected: (selectedColorOption == colorOption))
                return cell
        }
    }
    // Delegate funcs
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
                let tappedEmoji = availableEmojis[indexPath.item]
                selectedEmoji = (selectedEmoji == tappedEmoji) ? nil : tappedEmoji
            } else {
                let tappedColorOption = availableColors[indexPath.item]
                    selectedColorOption = (selectedColorOption == tappedColorOption) ? nil : tappedColorOption
                print(" Нажат цвет: \(selectedColorOption?.name ?? "Сброшен")")

            }
            collectionView.reloadData()
        }
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        table.separatorStyle = .singleLine
        return table
    }()
    
    private  lazy var textField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.layer.cornerRadius = 16
        text.placeholder = "Введите название трекера"
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        text.leftView = paddingView
        text.leftViewMode = .always
        text.backgroundColor = .backgroundDay
        return text
    }()
    
    private  lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.text = "Новая привычка"
        return label
    }()
    
    private  lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .red).cgColor
        button.backgroundColor = .whiteDay
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(resource: .red), for: .normal)
        return button
    }()
    
    private  lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(resource: .gray)
        button.tintColor = UIColor(resource: .whiteDay)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .whiteDay)
        tableView.dataSource = self
        tableView.delegate = self
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateButtonStyle()
        setUpViews()
        constraintsActivate()
        // hide keyboard
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        textField.returnKeyType = .done
    }
    private func setUpViews() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(textField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    
    
    private func constraintsActivate() {
        NSLayoutConstraint.activate([
            // Заголовок вверху
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            // Кнопки внизу (фиксированные)
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            // СкроллВью между заголовком и кнопками
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            // КонтентВью внутри скролла
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Поле ввода текста
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // Таблица (Категория / Расписание)
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Коллекция Emoji (3 ряда по 6 штук = 18 элементов)
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 245), // Высота под хедер + 3 ряда ячеек
            
            // Коллекция Цвет
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 280), // Высота под хедер цветов
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    private func updateButtonStyle() {
        let hasText = !(textField.text?.isEmpty ?? true)
        let hasSchedule = !selectedDays.isEmpty
        
        if hasText && hasSchedule {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(resource: .blackDay)
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(resource: .gray)
        }
    }
    func didSelectScheduleDays(_ days: [WeekDays]) {
        self.selectedDays = days
        updateButtonStyle()
        if days.count == 7 {
            scheduleSubtitle = "Каждый день"
        } else {
            scheduleSubtitle = days.map { $0.shortName }.joined(separator: ", ")
        }
        tableView.reloadData()
    }
    @objc private func createButtonTapped() {
        guard let titleText = textField.text, !titleText.isEmpty else { return }
        let finalColor = selectedColorOption?.name ?? "ColorSection1" // если не выбран цвет
        let finalEmoji = selectedEmoji ?? "😀" // если не выбран эмодзи
        print(finalColor)

        let newTracker = Tracker(
            id: UUID(),
            name: titleText,
            color: finalColor,
            emoji: finalEmoji,
            schedule: selectedDays
        )
        delegate?.didCreateTracker(newTracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateButtonStyle()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle ,reuseIdentifier: "cell")
        
        cell.textLabel?.text = options[indexPath.row]
        cell.backgroundColor = UIColor(resource: .backgroundDay)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = nil
            
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = scheduleSubtitle
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        }
        return cell
    }
}

extension HabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}
extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}
