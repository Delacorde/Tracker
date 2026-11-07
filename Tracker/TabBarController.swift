import UIKit

class TabBarController: UITabBarController{
    private var persistenceContainer = PersistenceContainer()
    
    init(persistenceContainer: PersistenceContainer) {
        self.persistenceContainer = persistenceContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tabBar.tintColor = .colorSection3
        let mainVC = TrackerViewController(
            trackerStore: persistenceContainer.trackerStore,
            categoryStore: persistenceContainer.categoryStore,
            recordStore: persistenceContainer.recordStore,
            persistenceContainer: persistenceContainer

        )
        mainVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .grayCircle) , selectedImage: UIImage(resource: .grayCircle)
        )
        
        let statisticsVC = UIViewController()
        statisticsVC.view.backgroundColor = .white
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .hare),
            selectedImage: UIImage(resource: .hare)
        )
        let mainNC = UINavigationController(rootViewController: mainVC)
        let statisticsNC = UINavigationController(rootViewController: statisticsVC)
        
        mainNC.setNavigationBarHidden(true, animated: false)
        statisticsNC.setNavigationBarHidden(true, animated: false)
        
        setViewControllers([mainNC, statisticsNC], animated: false)
    }
}
