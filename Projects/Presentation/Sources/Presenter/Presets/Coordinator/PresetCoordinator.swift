//
//  PresetCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import UIKit
import Domain
import Core
public final class PresetCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    private let dependencies: PresentationDependencyProviding
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    public let adMobRepo = AdmobRepository()
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
    }
    
    public func start() {
        showProfileInsertVC()
    }

}

extension PresetCoordinator {
    
    public func showProfileInsertVC() {
        let viewController = ProfileInsertVC(
            viewModel: ProfileInsertVM(
                coordinator: self,
                profileInsertUseCase: ProfileInsertUseCase(
                    userRepository: dependencies.makeUserRepository())
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showPermissionVC1() {
        let viewController = PermissionVC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(
                    firebaseService: dependencies.firebaseService,
                    userRepository: dependencies.makeUserRepository(),
                    coupleRepository: dependencies.makeCoupleRepository(),
                    adMobRepo: self.adMobRepo,
                    sharedDataRepo: dependencies.sharedDataRepo,
                    notificationService: dependencies.pushNotificationService
                ),
                pushNotificationService: dependencies.pushNotificationService
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showPermissionVC2() {
        let viewController = Permission2VC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(
                    firebaseService: dependencies.firebaseService,
                    userRepository: dependencies.makeUserRepository(),
                    coupleRepository: dependencies.makeCoupleRepository(),
                    adMobRepo: self.adMobRepo,
                    sharedDataRepo: dependencies.sharedDataRepo,
                    notificationService: dependencies.pushNotificationService
                ),
                pushNotificationService: dependencies.pushNotificationService
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension PresetCoordinator: CoordinatorDelegate {
    public func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators.removeAll()
        self.delegate?.didFinish(childCoordinator: self)
    }
}
