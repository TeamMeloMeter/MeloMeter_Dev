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

extension MainCoordinator: CoordinatorDelegate {
    
    func showMapVC() {
        let viewController = MapVC(viewModel: MapVM(
            coordinator: self,
            mainUseCase: MainUseCase(locationService: DefaultLocationService())
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
   
    func showDdayFlow() {
        let dDayCoordinator = DdayCoordinator(self.navigationController)
        childCoordinators.append(dDayCoordinator)
        dDayCoordinator.parentCoordinator = self
        dDayCoordinator.start()
    }

    func didFinish(childCoordinator: Coordinator) {
        print("didFinish")
        if childCoordinator is DdayCoordinator {
            self.navigationController.popViewController(animated: false)
        }
    }
}
