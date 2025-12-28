//
//  DdayCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/14.
//

import UIKit
import Domain
import Data
import Core
public final class DdayCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    
    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    public func start() {
        showDdayVC()
    }

}

extension DdayCoordinator {
    
    public func showDdayVC() {
        let viewController = DdayVC(viewModel: DdayVM(coordinator: self,
                                                      dDayUseCase: DdayUseCase(coupleRepository: CoupleRepository(firebaseService: DefaultFirebaseService()))))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showAddDdayVC(viewModel: DdayVM) {
        let viewController = AddDdayModal(viewModel: viewModel)
        viewController.modalPresentationStyle = .custom
        self.navigationController.present(viewController, animated: true, completion: nil)
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension DdayCoordinator: CoordinatorDelegate {
    public func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = []
        if childCoordinator is DdayCoordinator {
            self.navigationController.popViewController(animated: false)
        }
    }
}
