import UIKit

protocol HabitViewDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class HabitViewController: UIViewController, ScheduleViewControllerDelegate, UITextFieldDelegate {
    
    private var selectedDays:[WeekDays] = []
    private var scheduleSubtitle: String?
    weak var delegate: HabitViewDelegate?
    private let options = ["Категория", "Расписание"]

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.isScrollEnabled = false
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
        view.addSubview(textField)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(tableView)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
   
    
    private func constraintsActivate() {
        NSLayoutConstraint.activate([

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),

            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.heightAnchor.constraint(equalToConstant: 75),

            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.heightAnchor.constraint(equalToConstant: 150)
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
        
        let newTracker = Tracker(
         id: UUID(),
         name: titleText,
         color: "ColorSection2",
         emoji: "😎",
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
