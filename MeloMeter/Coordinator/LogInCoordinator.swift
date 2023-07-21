//
//  LogInCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit

final class LogInCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }

    func start() {
        showPhoneCertifiedVC()
    }
}

extension LogInCoordinator {
    
    func showPhoneCertifiedVC() {
        let viewController = PhoneCertifiedVC(viewModel: LogInVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAuthNumVC(phoneNumber: String?) {
        let viewModel = LogInVM(coordinator: self)
        viewModel.phoneNumber = phoneNumber
        let viewController = AuthNumVC(viewModel: viewModel)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCoupleComvineVC() {
        let viewController = CoupleCombineVC(viewModel: LogInVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfileInsertVC() {
        let viewController = ProfileInsertVC(viewModel: LogInVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

}
