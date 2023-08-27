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

extension MyProfileCoordinator {
    
    func showMyProfileVC() {
    let firebaseService = DefaultFirebaseService()
        let viewController = MyProfileVC(viewModel: MyProfileVM(
            coordinator: self,
            myProfileUseCase: MyProfileUseCase(
                        userRepository: UserRepository(
                            firebaseService: firebaseService
                        ),
                        coupleRepository: CoupleRepository(firebaseService: firebaseService)
                    )
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
    
    func showHundredQAFlow() {
        let hundredQACoordinator = HundredCoordinator(self.navigationController)
        childCoordinators.append(hundredQACoordinator)
        hundredQACoordinator.delegate = self
        hundredQACoordinator.start()
    }
    
    func showEditProfileVC() {
        let firebaseService = DefaultFirebaseService()
        let userRepository = UserRepository(
            firebaseService: firebaseService
        )
        let viewController = EditProfileVC(viewModel: EditProfileVM(
            coordinator: self,
            editProfileUseCase: EditProfileUseCase(userRepository: userRepository),
            accountsUseCase: AccountsUseCase(userRepository: userRepository,
                                             coupleRepository: CoupleRepository(firebaseService: firebaseService))
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
    
    func showNoticeVC() {
        let viewController = NoticeVC(viewModel: NoticeVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showDetailNoticeVC() {
        let viewController = DetailNoticeVC(viewModel: NoticeVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showQnAVC() {
        let viewController = QnAVC(viewModel: QnAVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showDetailQnAVC(title: String, contents: String) {
        let viewController = DetailQnAVC(viewModel: QnAVM(coordinator: self), title: title, contents: contents)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showDisconnectVC() {
        let firebaseService = DefaultFirebaseService()
        let viewController = DisconnectVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: UserRepository(firebaseService: firebaseService),
                coupleRepository: CoupleRepository(firebaseService: firebaseService)
            ))
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showRecoveryVC(date: (String, String), names: (String, String)) {
        let firebaseService = DefaultFirebaseService()
        let viewController = RecoveryVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: UserRepository(firebaseService: firebaseService),
                coupleRepository: CoupleRepository(firebaseService: firebaseService)
            )),
                                        date: date,
                                        names: names
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWithdrawalVC() {
        let firebaseService = DefaultFirebaseService()
        let viewController = WithdrawalVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: UserRepository(firebaseService: DefaultFirebaseService()),
                coupleRepository: CoupleRepository(firebaseService: firebaseService)
            ))
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func recoverySuccess() {
        self.navigationController.viewControllers.removeAll()
        self.showMyProfileVC()
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension MyProfileCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        
        print("myprofile", childCoordinator)
        
        if childCoordinator is DdayCoordinator || childCoordinator is AlarmCoordinator || childCoordinator is HundredCoordinator {
            self.navigationController.popViewController(animated: true)
            self.childCoordinators.removeLast()
        }else {
            self.childCoordinators = []
            childCoordinator.navigationController.popToRootViewController(animated: true)
        }
    }
    
}
