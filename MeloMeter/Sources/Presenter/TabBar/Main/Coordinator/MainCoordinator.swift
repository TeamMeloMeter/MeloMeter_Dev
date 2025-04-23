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
    
    private let firebaseService = DefaultFirebaseService()
    private let adMobRepo = AdmobRepository()
    private let sharedDataRepo: SharedDataRepoP
    
    init(_ navigationController: UINavigationController, sharedDataRepo: SharedDataRepoP) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.sharedDataRepo = sharedDataRepo
    }
    
    func start() {
        showMapVC()
    }

}

extension MainCoordinator {
    
    func showMapVC() {
        let firebaseService = self.firebaseService
        let viewController = MapVC(viewModel: MapVM(
            coordinator: self,
            mainUseCase: MainUseCase(firebaseService: firebaseService, adMobRepo: self.adMobRepo, sharedDataRepo: self.sharedDataRepo)
        )
        )
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
   
    func showAlarmFlow() {
        let alarmCoordinator = AlarmCoordinator(self.navigationController)
        childCoordinators.append(alarmCoordinator)
        alarmCoordinator.delegate = self
        alarmCoordinator.start()
    }
    
    func showDdayFlow() {
        let dDayCoordinator = DdayCoordinator(self.navigationController)
        childCoordinators.append(dDayCoordinator)
        dDayCoordinator.delegate = self
        dDayCoordinator.start()
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
}

extension MainCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = []
        if childCoordinator is DdayCoordinator || childCoordinator is AlarmCoordinator {
            self.navigationController.popViewController(animated: true)
        }
    }
}
