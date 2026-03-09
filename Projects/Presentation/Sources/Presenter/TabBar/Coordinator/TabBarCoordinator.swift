//
//  TabBarCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public final class TabBarCoordinator: Coordinator {
  public var delegate: CoordinatorDelegate?
  public var tabBarController: UITabBarController
  public var navigationController: UINavigationController
  public var childCoordinators: [Coordinator]
  private let dependencies: PresentationDependencyProviding
  
  
  
  
  public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
    self.navigationController = navigationController
    self.tabBarController = UITabBarController()
    self.childCoordinators = []
    self.dependencies = dependencies
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
//    applyOpaqueTabBarAppearance()
    self.navigationController.setNavigationBarHidden(true, animated: false)
    self.navigationController.pushViewController(tabBarController, animated: true)
  }
  
  public func createTabNavigationController(of page: TabBarPageType) -> UINavigationController {
    let tabNavigationController = UINavigationController()
    tabNavigationController.setNavigationBarHidden(false, animated: false)
    applyOpaqueNavigationAppearance(to: tabNavigationController)
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
    case .calendar:
      self.connectCalendarFlow(to: tabNavigationController)
    case .myPage:
      self.connectMyProfileFlow(to: tabNavigationController)
    }
  }
  
  public func connectMainFlow(to tabNavigationController: UINavigationController) {
    let mainCoordinator = MainCoordinator(tabNavigationController, dependencies: dependencies)
    mainCoordinator.delegate = self
    mainCoordinator.start()
    childCoordinators.append(mainCoordinator)
  }
  
  public func connectMyProfileFlow(to tabNavigationController: UINavigationController) {
    let myProfileCoordinator = MyProfileCoordinator(tabNavigationController, dependencies: dependencies)
    myProfileCoordinator.delegate = self
    myProfileCoordinator.start()
    childCoordinators.append(myProfileCoordinator)
  }
  
  public func connectChatFlow(to tabNavigationController: UINavigationController) {
    let chatCoordinator = ChatCoordinator(tabNavigationController, dependencies: dependencies)
    chatCoordinator.delegate = self
    chatCoordinator.start()
    childCoordinators.append(chatCoordinator)
  }
  
  public func connectCalendarFlow(to tabNavigationController: UINavigationController) {
      let repo = dependencies.makeDatePlanRepository()
      let useCase = DatePlanUseCaseImpl(repository: repo)
      let vm = SharedCalendarVM(useCase: useCase)
      let vc = SharedCalendarVC(viewModel: vm)
      tabNavigationController.pushViewController(vc, animated: false)
  }
  
  public func finish() {
    self.delegate?.didFinish(childCoordinator: self)
  }
}

private extension TabBarCoordinator {
//  func applyOpaqueTabBarAppearance() {
//    if #available(iOS 15.0, *) {
//      let appearance = UITabBarAppearance()
//      appearance.configureWithOpaqueBackground()
//      appearance.backgroundColor = .white
//      appearance.shadowColor = .clear
//      tabBarController.tabBar.standardAppearance = appearance
//      tabBarController.tabBar.scrollEdgeAppearance = appearance
//    }
//    tabBarController.tabBar.isTranslucent = false
//  }
  
  func applyOpaqueNavigationAppearance(to navigationController: UINavigationController) {
    if #available(iOS 15.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = .white
      appearance.shadowColor = .clear
      if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance
      }
      navigationController.navigationBar.standardAppearance = appearance
      navigationController.navigationBar.scrollEdgeAppearance = appearance
      navigationController.navigationBar.compactAppearance = appearance
      if #available(iOS 16.0, *) {
        navigationController.navigationBar.compactScrollEdgeAppearance = appearance
      }
    }
    navigationController.navigationBar.isTranslucent = false
    if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
      navigationController.navigationBar.backIndicatorImage = backImage
      navigationController.navigationBar.backIndicatorTransitionMaskImage = backImage
    }
    navigationController.navigationBar.tintColor = .gray1
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
