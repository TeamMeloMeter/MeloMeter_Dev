//
//  AppCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    // MARK: - Initializers
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    // MARK: - Methods
    func start() {
        showStartVC()
    }
    
}

// MARK: - connectFlow Methods
extension AppCoordinator {
    
    func showStartVC() {
        let startVC = ProfileInsertVC(viewModel: ProfileInsertVM(coordinator: self))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(startVC, animated: false)
    }
    func connectLogInFlow(_ inviteCode: String? = nil) {
        self.navigationController.viewControllers.removeAll()
        let logInCoordinator = LogInCoordinator(self.navigationController)
        logInCoordinator.delegate = self
        logInCoordinator.inviteCode2 = inviteCode
        logInCoordinator.start()
        self.childCoordinators.append(logInCoordinator)
    }

//    func connectTabBarFlow() {
//        self.navigationController.popToRootViewController(animated: true)
//        let tabBarCoordinator = TabBarCoordinator(self.navigationController)
//        tabBarCoordinator.delegate = self
//        tabBarCoordinator.start()
//        self.childCoordinators.append(tabBarCoordinator)
//    }
    

}

// MARK: - Coodinator Delegate
extension AppCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        self.navigationController.popToRootViewController(animated: true)
        self.connectLogInFlow()
    }
}
