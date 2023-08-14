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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        navigationController.navigationBar.standardAppearance = appearance
        
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showMyProfileVC()
    }

}

extension MyProfileCoordinator: CoordinatorDelegate {
    
    func showMyProfileVC() {
        let viewController = MyProfileVC(viewModel: MyProfileVM(
            coordinator: self,
            myProfileUseCase: MyProfileUseCase(
                        userRepository: UserRepository(
                            firebaseService: DefaultFirebaseService()
                        )
                    )
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
    
    func showEditProfileVC() {
        let viewController = EditProfileVC(viewModel: EditProfileVM(
            coordinator: self,
            editProfileUseCase: EditProfileUseCase(
                        userRepository: UserRepository(
                            firebaseService: DefaultFirebaseService()
                        )
                    )
            )
        )
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEditNameVC(name: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: UserRepository(
                                              firebaseService: DefaultFirebaseService()
                                          )
                                      )
                              )
        viewModel.name = name
        
        let viewController = EditNameVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEditStateMessageVC(stateMessage: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: UserRepository(
                                              firebaseService: DefaultFirebaseService()
                                          )
                                      )
                              )
        viewModel.stateMessage = stateMessage
        
        let viewController = EditStateMessageVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEditBirthVC(birth: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: UserRepository(
                                              firebaseService: DefaultFirebaseService()
                                          )
                                      )
                              )
        viewModel.birth = birth
        
        let viewController = EditBirthVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func didFinish(childCoordinator: Coordinator) {
        if childCoordinator is DdayCoordinator {
            childCoordinators.removeLast()
            self.navigationController.popViewController(animated: false)
        }
    }
    
}

