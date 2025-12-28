//
//  TabBarCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit
import Domain
import Data
import Core

public final class TabBarCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    public var tabBarController: UITabBarController
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    private var sharedDataRepo: SharedDataRepoP
    
 
    
    
    public init(_ navigationController: UINavigationController, sharedDataRepo: SharedDataRepoP) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        self.childCoordinators = []
        
        self.sharedDataRepo = sharedDataRepo
    }
    
    public func start() {
        let pages: [TabBarPageType] = TabBarPageType.allCases
        let controllers: [UINavigationController] = pages.map {
            self.createTabNavigationController(of: $0)
        }
        self.configureTabBarController(with: controllers)
        
    }
    
    public func currentPage() -> TabBarPageType? {
        return TabBarPageType(rawValue: self.tabBarController.selectedIndex)
    }
    
    public func selectPage(_ page: TabBarPageType) {
        self.tabBarController.selectedIndex = page.rawValue
    }
    
    public func setSelectedIndex(_ index: Int) {
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
    
    public func createTabNavigationController(of page: TabBarPageType) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        tabNavigationController.setNavigationBarHidden(false, animated: false)
        tabNavigationController.tabBarItem = page.tabBarItem
        connectTabCoordinator(of: page, to: tabNavigationController)
        return tabNavigationController
    }
    
    public func connectTabCoordinator(of page: TabBarPageType, to tabNavigationController: UINavigationController) {
        switch page {
        case .main:
            self.connectMainFlow(to: tabNavigationController)
        case .chat:
            self.connectChatFlow(to: tabNavigationController)
        case .myPage:
            self.connectMyProfileFlow(to: tabNavigationController)
        }
    }
    
    public func connectMainFlow(to tabNavigationController: UINavigationController) {
        let mainCoordinator = MainCoordinator(tabNavigationController, sharedDataRepo: self.sharedDataRepo)
        mainCoordinator.delegate = self
        mainCoordinator.start()
        childCoordinators.append(mainCoordinator)
    }
    
    public func connectMyProfileFlow(to tabNavigationController: UINavigationController) {
        let myProfileCoordinator = MyProfileCoordinator(tabNavigationController)
        myProfileCoordinator.delegate = self
        myProfileCoordinator.start()
        childCoordinators.append(myProfileCoordinator)
    }
    
    public func connectChatFlow(to tabNavigationController: UINavigationController) {
        let chatCoordinator = ChatCoordinator(tabNavigationController)
        chatCoordinator.delegate = self
        chatCoordinator.start()
        childCoordinators.append(chatCoordinator)
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
}

extension TabBarCoordinator: CoordinatorDelegate {
    
    
    public func didFinish(childCoordinator: Coordinator) {        
        if childCoordinator is ChatCoordinator {
            self.selectPage(.main)
        }else {
            self.childCoordinators.removeAll()
            self.finish()
        }
        
    }
   
}
