//
//  MyProfileCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import Domain
import Core
public final class MyProfileCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    private let dependencies: PresentationDependencyProviding
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        let appearance = UINavigationBarAppearance()
       
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance
        }
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        if #available(iOS 16.0, *) {
            navigationController.navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationController.navigationBar.isTranslucent = false
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            navigationController.navigationBar.backIndicatorImage = backImage
            navigationController.navigationBar.backIndicatorTransitionMaskImage = backImage
        }
        navigationController.navigationBar.tintColor = .gray1
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
        
    }
    public func start() {
        showMyProfileVC()
    }

}

extension MyProfileCoordinator {
    
    public func showMyProfileVC() {
        let chatRepository = dependencies.makeChatRepository()
        let userRepository = dependencies.makeUserRepository(chatRepository: chatRepository)
        let viewController = MyProfileVC(viewModel: MyProfileVM(
            coordinator: self,
            myProfileUseCase: MyProfileUseCase(
                        userRepository: userRepository,
                        coupleRepository: dependencies.makeCoupleRepository(),
                        hundredQARepository: dependencies.makeHundredQARepository(),
                        adMobRepo: AdmobRepository()
            ),
            alarmUseCase: AlarmUseCase(alarmRepository: dependencies.makeAlarmRepository())
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func showAlarmFlow() {
        let alarmCoordinator = AlarmCoordinator(self.navigationController, dependencies: dependencies)
        childCoordinators.append(alarmCoordinator)
        alarmCoordinator.delegate = self
        alarmCoordinator.start()
    }
    
    public func showDdayFlow() {
        let dDayCoordinator = DdayCoordinator(self.navigationController, dependencies: dependencies)
        childCoordinators.append(dDayCoordinator)
        dDayCoordinator.delegate = self
        dDayCoordinator.start()
    }
    
    public func showHundredQAFlow() {
        let hundredQACoordinator = HundredCoordinator(self.navigationController, dependencies: dependencies)
        childCoordinators.append(hundredQACoordinator)
        hundredQACoordinator.delegate = self
        hundredQACoordinator.start()
    }
    
    public func showEditProfileVC() {
        let chatRepository = dependencies.makeChatRepository()
        let userRepository = dependencies.makeUserRepository(chatRepository: chatRepository)
        let viewController = EditProfileVC(viewModel: EditProfileVM(
            coordinator: self,
            editProfileUseCase: EditProfileUseCase(userRepository: userRepository),
            accountsUseCase: AccountsUseCase(userRepository: userRepository,
                                             coupleRepository: dependencies.makeCoupleRepository())
            )
        )
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showEditNameVC(name: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: dependencies.makeUserRepository()
                                      )
                              )
        viewModel.name = name
        
        let viewController = EditNameVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showEditStateMessageVC(stateMessage: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: dependencies.makeUserRepository()
                                      )
                              )
        viewModel.stateMessage = stateMessage
        
        let viewController = EditStateMessageVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showEditBirthVC(birth: String) {
        let viewModel = DetailEditVM(coordinator: self,
                              editProfileUseCase: EditProfileUseCase(
                                          userRepository: dependencies.makeUserRepository()
                                      )
                              )
        viewModel.birth = birth
        
        let viewController = EditBirthVC(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showNoticeVC() {
        let viewController = NoticeVC(viewModel: NoticeVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showDetailNoticeVC() {
        let viewController = DetailNoticeVC(viewModel: NoticeVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showQnAVC() {
        let viewController = QnAVC(viewModel: QnAVM(coordinator: self))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showDetailQnAVC(title: String, contents: String) {
        let viewController = DetailQnAVC(viewModel: QnAVM(coordinator: self), title: title, contents: contents)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showDisconnectVC() {
        let viewController = DisconnectVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: dependencies.makeUserRepository(),
                coupleRepository: dependencies.makeCoupleRepository()
            ))
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showRecoveryVC(date: (String, String), names: (String, String)) {
        let viewController = RecoveryVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: dependencies.makeUserRepository(),
                coupleRepository: dependencies.makeCoupleRepository()
            )),
                                        date: date,
                                        names: names
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    //MARK: 회원탈퇴 VC
    public func showWithdrawalVC() {
        let viewController = WithdrawalVC(viewModel: AccountsVM(
            coordinator: self,
            accountsUseCase: AccountsUseCase(
                userRepository: dependencies.makeUserRepository(),
                coupleRepository: dependencies.makeCoupleRepository()
            ))
        )
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func recoverySuccess() {
        self.navigationController.viewControllers.removeAll()
        self.showMyProfileVC()
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension MyProfileCoordinator: CoordinatorDelegate {
    public func didFinish(childCoordinator: Coordinator) {
        
        if childCoordinator is DdayCoordinator || childCoordinator is AlarmCoordinator || childCoordinator is HundredCoordinator {
            self.navigationController.popViewController(animated: true)
            self.childCoordinators.removeLast()
        }else {
            self.childCoordinators = []
            childCoordinator.navigationController.popToRootViewController(animated: true)
        }
    }
    
}
