//
//  MainCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit
final class MainCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showMapVC()
    }

}

extension MainCoordinator {
    
    func showMapVC() {
        let viewController = MapVC(viewModel: MapVM(
            coordinator: self,
            mainUseCase: MainUseCase(
                locationService: DefaultLocationService()
                )
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
   
//    func showPermissionVC2() {
//        let viewController = Permission2VC(viewModel: PermissionVM(coordinator: LogInCoordinator(UINavigationController())))
//        
//        self.navigationController.setNavigationBarHidden(true, animated: false)
//        self.navigationController.pushViewController(viewController, animated: true)
//    }

}
