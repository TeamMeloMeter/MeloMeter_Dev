//
//  AlarmCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/21.
//

import UIKit
import Domain
import Core
public final class AlarmCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    private let dependencies: PresentationDependencyProviding
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
    }
    
    public func start() {
        showAlarmVC()
    }

}

extension AlarmCoordinator {
    
    public func showAlarmVC() {
        let viewController = AlarmVC(
            viewModel: AlarmVM(
                coordinator: self,
                alarmUseCase: AlarmUseCase(alarmRepository: dependencies.makeAlarmRepository())
            )
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}
