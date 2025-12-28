//
//  PresetCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import UIKit
import Domain
import Data
import Core
public final class PresetCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    private let sharedDataRepo: SharedDataRepoP
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    public let firebaseService = DefaultFirebaseService()
    public let adMobRepo = AdmobRepository()
    
    public init(_ navigationController: UINavigationController, sharedDataRepo: SharedDataRepoP) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.sharedDataRepo = sharedDataRepo
    }
    
    public func start() {
        showProfileInsertVC()
    }

}

extension PresetCoordinator {
    
    public func showProfileInsertVC() {
        let firebaseService = self.firebaseService
        let viewController = ProfileInsertVC(
            viewModel: ProfileInsertVM(
                coordinator: self,
                profileInsertUseCase: ProfileInsertUseCase(
                    userRepository: UserRepository(firebaseService: firebaseService,
                                                   chatRepository: ChatRepository(firebaseService: firebaseService)))
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showPermissionVC1() {
        let firebaseService = self.firebaseService
        let chatRepository = ChatRepository(firebaseService: firebaseService)
        let userRepository = UserRepository(firebaseService: firebaseService, chatRepository: chatRepository)
        let coupleRepository = CoupleRepository(firebaseService: firebaseService)
        let viewController = PermissionVC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(
                    firebaseService: firebaseService,
                    userRepository: userRepository,
                    coupleRepository: coupleRepository,
                    adMobRepo: self.adMobRepo,
                    sharedDataRepo: self.sharedDataRepo,
                    notificationService: PushNotificationService.shared
                )
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showPermissionVC2() {
        let firebaseService = self.firebaseService
        let chatRepository = ChatRepository(firebaseService: firebaseService)
        let userRepository = UserRepository(firebaseService: firebaseService, chatRepository: chatRepository)
        let coupleRepository = CoupleRepository(firebaseService: firebaseService)
        let viewController = Permission2VC(
            viewModel: PermissionVM(
                coordinator: self,
                mainUseCase: MainUseCase(
                    firebaseService: firebaseService,
                    userRepository: userRepository,
                    coupleRepository: coupleRepository,
                    adMobRepo: self.adMobRepo,
                    sharedDataRepo: self.sharedDataRepo,
                    notificationService: PushNotificationService.shared
                )
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
