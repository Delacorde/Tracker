import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectScheduleDays(_ selectedDays: [WeekDays])
}
final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private let weekDaysList = [
        NSLocalizedString("Monday", comment: "monday"),
        NSLocalizedString("Tuesday", comment: "tuesday"),
        NSLocalizedString("Wednesday", comment: "sreda"),
        NSLocalizedString("Thursday", comment: "chetverg"),
        NSLocalizedString("Friday", comment: "friday"),
        NSLocalizedString("Saturday", comment: "subota"),
        NSLocalizedString("Sunday", comment: "sunday")
    ]
    private var chosenWeekDays: [WeekDays] = []
    func configureSelectedDays(_ days: [WeekDays]) {
        chosenWeekDays = days

        if isViewLoaded {
            scheduleTableView.reloadData()
        }
    }
        private let cellReuseIdentifier = "ScheduleTableCell"
    private lazy var scheduleTableView: UITableView = {
            let tableView = UITableView(frame: .zero, style: .insetGrouped)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.isScrollEnabled = false
        tableView.backgroundColor = Colors().viewBackground
            return tableView
        }()
    private lazy var navigationTitleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors().headerColor
            label.text = NSLocalizedString("Schedule", comment: "raspisanie")
            return label
        }()
    private lazy var submitButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 16
        button.backgroundColor = Colors().headerColor
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle(NSLocalizedString("Done", comment: "done"), for: .normal)
        button.setTitleColor(Colors().viewBackground, for: .normal)
        button.tintColor = Colors().viewBackground
            return button
        }()
    override func viewDidLoad() {
            super.viewDidLoad()
        view.backgroundColor = Colors().viewBackground
            
            scheduleTableView.dataSource = self
            scheduleTableView.delegate = self
            scheduleTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            
            configureSubviews()
            configureConstraints()
        }
    private func configureSubviews() {
            view.addSubview(scheduleTableView)
            view.addSubview(navigationTitleLabel)
            view.addSubview(submitButton)
            
            submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        }
    private func configureConstraints() {
            NSLayoutConstraint.activate([
                navigationTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                navigationTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
                
                scheduleTableView.topAnchor.constraint(equalTo: navigationTitleLabel.bottomAnchor, constant: 30),
                scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
                
                submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                submitButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
    @objc private func handleSwitchToggle(_ sender: UISwitch) {
            let targetDay = WeekDays.allCases[sender.tag]
            
            if sender.isOn {
                chosenWeekDays.append(targetDay)
                print("В массив добавился день: \(targetDay)")
            } else {
                chosenWeekDays.removeAll { $0 == targetDay }
                print("Из массива удалился день: \(targetDay)")
            }
        }
        
        @objc private func submitButtonTapped() {
            delegate?.didSelectScheduleDays(chosenWeekDays)
            navigationController?.popViewController(animated: true)
        }
    }
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDaysList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        let toggleSwitch = UISwitch(frame: .zero)

        let currentDay = WeekDays.allCases[indexPath.row]
        toggleSwitch.isOn = chosenWeekDays.contains(currentDay)
        
        toggleSwitch.isOn = false
        toggleSwitch.onTintColor = .blue
        toggleSwitch.tag = indexPath.row
        toggleSwitch.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
        
        cell.accessoryView = toggleSwitch
        cell.textLabel?.text = weekDaysList[indexPath.row]
        cell.backgroundColor = UIColor(resource: .backgroundDay)
        return cell
    }
}
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
