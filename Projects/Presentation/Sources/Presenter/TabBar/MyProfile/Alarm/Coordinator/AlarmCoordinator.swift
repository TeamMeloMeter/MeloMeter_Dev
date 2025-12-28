//
//  AlarmCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/21.
//

import UIKit
import Domain
import Data
import Core
public final class AlarmCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    
    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    public func start() {
        showAlarmVC()
    }

}

extension AlarmCoordinator {
    
    public func showAlarmVC() {
        let viewController = AlarmVC(viewModel: AlarmVM(coordinator: self, alarmUseCase: AlarmUseCase(alarmRepository: AlarmRepository(firebaseService: DefaultFirebaseService()))))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}
