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
        let viewController = ProfileInsertVC(
            viewModel: ProfileInsertVM(
                coordinator: self,
                profileInsertUseCase: ProfileInsertUseCase(profileInsertRepository: ProfileInsertRepository()))
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC1() {
        let viewController = PermissionVC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(locationService: DefaultLocationService()))
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC2() {
        let viewController = Permission2VC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(locationService: DefaultLocationService()))
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

}
