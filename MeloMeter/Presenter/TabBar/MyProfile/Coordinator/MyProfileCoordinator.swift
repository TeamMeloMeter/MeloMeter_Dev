//
//  MyProfileCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
final class MyProfileCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showMyProfileVC()
    }

}

extension MyProfileCoordinator {
    
    func showMyProfileVC() {
        let viewController = MyProfileVC(viewModel: MyProfileVM(
            coordinator: self,
            myProfileUseCase: MyProfileUseCase(userRepository:
                                                UserRepository(
                                                    firebaseService: DefaultFirebaseService()
                                                )
                                              )
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
   

}
