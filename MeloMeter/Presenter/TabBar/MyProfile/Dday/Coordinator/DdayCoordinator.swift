//
//  DdayCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/14.
//

import UIKit
final class DdayCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showDdayVC()
    }

}

extension DdayCoordinator {
    
    func showDdayVC() {
        let viewController = DdayVC(viewModel: DdayVM(coordinator: self,
                                                      dDayUseCase: DdayUseCase(coupleRepository: CoupleRepository(firebaseService: DefaultFirebaseService()))))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddDdayVC(viewModel: DdayVM) {
        let viewController = AddDdayModal(viewModel: viewModel)
        viewController.modalPresentationStyle = .custom
        self.navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension DdayCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = []
        print("ddayCodi", childCoordinator)
        if childCoordinator is DdayCoordinator {
            self.navigationController.popViewController(animated: false)
        }
    }
}
