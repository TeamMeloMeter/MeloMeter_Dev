//
//  AlarmCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/21.
//

import UIKit
final class AlarmCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showAlarmVC()
    }

}

extension AlarmCoordinator {
    
    func showAlarmVC() {
        let viewController = AlarmVC(viewModel: AlarmVM(coordinator: self, alarmUseCase: AlarmUseCase(alarmRepository: AlarmRepository(firebaseService: DefaultFirebaseService()))))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}
