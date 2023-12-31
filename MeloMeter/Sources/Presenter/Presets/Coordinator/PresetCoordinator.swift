//
//  PresetCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import UIKit
final class PresetCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    let firebaseService = DefaultFirebaseService()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showProfileInsertVC()
    }

}

extension PresetCoordinator {
    
    func showProfileInsertVC() {
        let firebaseService = self.firebaseService
        let viewController = ProfileInsertVC(
            viewModel: ProfileInsertVM(
                coordinator: self,
                profileInsertUseCase: ProfileInsertUseCase(
                    userRepository: UserRepository(firebaseService: firebaseService,
                                                   chatRepository: ChatRepository(firebaseService: firebaseService)))
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC1() {
        let firebaseService = self.firebaseService
        let viewController = PermissionVC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(locationService: DefaultLocationService(firebaseService: firebaseService),
                                         firebaseService: firebaseService))
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC2() {
        let firebaseService = self.firebaseService
        let viewController = Permission2VC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(locationService: DefaultLocationService(firebaseService: firebaseService),
                                         firebaseService: firebaseService))
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension PresetCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators.removeAll()
        self.delegate?.didFinish(childCoordinator: self)
    }
}
