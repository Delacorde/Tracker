import UIKit

class TabBarController: UITabBarController{
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tabBar.tintColor = .blue
        let mainVC = ViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .grayCircle) , selectedImage: UIImage(resource: .grayCircle)
        )
        
        let statisticsVC = UIViewController()
        statisticsVC.view.backgroundColor = .white
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .grayRabbit),
            selectedImage: UIImage(resource: .grayRabbit)
        )
        let mainNC = UINavigationController(rootViewController: mainVC)
        let statisticsNC = UINavigationController(rootViewController: statisticsVC)
        
        setViewControllers([mainNC, statisticsNC], animated: false)
    }
}
