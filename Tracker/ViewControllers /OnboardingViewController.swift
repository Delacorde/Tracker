import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Properties
    private lazy var pages: [UIViewController] = [
        makePage(with: UIImage(resource: .firstPage),
                 text: "Отслеживайте только то, что хотите"),
        makePage(with: UIImage(resource: .secondPage),
                 text: "Даже если это не литры воды и йога")
    ]
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = UIColor(resource: .blackDay)
        control.pageIndicatorTintColor = .gray
        control.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(resource: .blackDay)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(UIColor(resource: .whiteDay), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.widthAnchor.constraint(equalToConstant: 335),
            skipButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Private Methods
    private func makePage(with image: UIImage, text: String) -> UIViewController {
        let controller = UIViewController()
        let imageView = UIImageView()
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        controller.view.addSubview(imageView)
        controller.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: controller.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            label.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 388),
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 16)
        ])
        
        return controller
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let index = sender.currentPage
        let currentVC = viewControllers?.first
        let currentIndex = currentVC.flatMap { pages.firstIndex(of: $0) } ?? 0
        
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
    
    @objc private func skipButtonTapped() {
        StorageModel.shared.hasSeenOnboarding = true
        showMainApp()
    }
    
    private func showMainApp() {
        let persistenceContainer = PersistenceContainer()
        let tabBarController = TabBarController(persistenceContainer: persistenceContainer)
        
        guard let window = view.window else { return }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: - DataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - Delegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: currentVC) else {
            return
        }
        pageControl.currentPage = index
    }
}
