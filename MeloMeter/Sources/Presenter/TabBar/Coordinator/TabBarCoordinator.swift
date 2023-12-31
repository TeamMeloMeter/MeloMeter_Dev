//
//  TabBarCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    var tabBarController: UITabBarController
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        self.childCoordinators = []
    }
    
    func start() {
        let pages: [TabBarPageType] = TabBarPageType.allCases
        let controllers: [UINavigationController] = pages.map {
            self.createTabNavigationController(of: $0)
        }
        self.configureTabBarController(with: controllers)
        
    }
    
    func currentPage() -> TabBarPageType? {
        return TabBarPageType(rawValue: self.tabBarController.selectedIndex)
    }
    
    func selectPage(_ page: TabBarPageType) {
        self.tabBarController.selectedIndex = page.rawValue
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPageType(rawValue: index) else { return }
        self.tabBarController.selectedIndex = page.rawValue
    }
    
}

extension TabBarCoordinator {
    
    private func configureTabBarController(with tabViewControllers: [UIViewController]) {
        self.tabBarController.setViewControllers(tabViewControllers, animated: true)
        self.tabBarController.selectedIndex = TabBarPageType.main.rawValue
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(tabBarController, animated: true)
    }
    
    func createTabNavigationController(of page: TabBarPageType) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        tabNavigationController.setNavigationBarHidden(false, animated: false)
        tabNavigationController.tabBarItem = page.tabBarItem
        connectTabCoordinator(of: page, to: tabNavigationController)
        return tabNavigationController
    }
    
    func connectTabCoordinator(of page: TabBarPageType, to tabNavigationController: UINavigationController) {
        switch page {
        case .main:
            self.connectMainFlow(to: tabNavigationController)
        case .chat:
            self.connectChatFlow(to: tabNavigationController)
        case .myPage:
            self.connectMyProfileFlow(to: tabNavigationController)
        }
    }
    
    func connectMainFlow(to tabNavigationController: UINavigationController) {
        let mainCoordinator = MainCoordinator(tabNavigationController)
        mainCoordinator.delegate = self
        mainCoordinator.start()
        childCoordinators.append(mainCoordinator)
    }
    
    func connectMyProfileFlow(to tabNavigationController: UINavigationController) {
        let myProfileCoordinator = MyProfileCoordinator(tabNavigationController)
        myProfileCoordinator.delegate = self
        myProfileCoordinator.start()
        childCoordinators.append(myProfileCoordinator)
    }
    
    func connectChatFlow(to tabNavigationController: UINavigationController) {
        let chatCoordinator = ChatCoordinator(tabNavigationController)
        chatCoordinator.delegate = self
        chatCoordinator.start()
        childCoordinators.append(chatCoordinator)
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
}

extension TabBarCoordinator: CoordinatorDelegate {
    
    
    func didFinish(childCoordinator: Coordinator) {        
        if childCoordinator is ChatCoordinator {
            self.selectPage(.main)
        }else {
            self.childCoordinators.removeAll()
            self.finish()
        }
        
    }
   
}
