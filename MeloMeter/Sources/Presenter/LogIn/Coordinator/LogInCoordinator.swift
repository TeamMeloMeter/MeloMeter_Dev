//
//  LogInCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
final class LogInCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    let firebaseService = DefaultFirebaseService()
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var isLogin: Bool = false
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        if !isLogin {
            showStartVC()
        }else {
            if let inviteCode = UserDefaults.standard.string(forKey: "inviteCode") {
                let code = "\(inviteCode.prefix(4)) \(inviteCode.suffix(4))"
                if let otherInviteCode = UserDefaults.standard.string(forKey: "otherInviteCode") {
                    showCoupleComvineVC(inviteCode: code, otherInviteCode: otherInviteCode)
                }else {
                    showCoupleComvineVC(inviteCode: code)
                }
            }
        }

    }

}

extension LogInCoordinator {
    func showStartVC() {
        let startVC = StartVC(viewModel: StartVM(coordinator: self))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(startVC, animated: false)
    }
    
    func showPhoneCertifiedVC() {
        let viewController = PhoneCertifiedVC(
            viewModel: LogInVM(
                coordinator: self,
                logInUseCase: LogInUseCase(logInRepository: LogInRepository(firebaseService: firebaseService),
                                           userRepository: UserRepository(firebaseService: firebaseService,
                                                                          chatRepository: ChatRepository(firebaseService: firebaseService)))
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAuthNumVC(phoneNumber: String?) {
        let viewModel = LogInVM(
            coordinator: self,
            logInUseCase: LogInUseCase(logInRepository: LogInRepository(firebaseService: firebaseService),
                                       userRepository: UserRepository(firebaseService: firebaseService,
                                                                      chatRepository: ChatRepository(firebaseService: firebaseService))
                                      )
        )
        viewModel.phoneNumber = phoneNumber
        let viewController = AuthNumVC(viewModel: viewModel)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCoupleComvineVC(inviteCode: String, otherInviteCode: String? = nil) {
        let viewController = CoupleCombineVC(
            viewModel: LogInVM(
                coordinator: self,
                logInUseCase: LogInUseCase(logInRepository: LogInRepository(firebaseService: firebaseService),
                                           userRepository: UserRepository(firebaseService: firebaseService,
                                                                          chatRepository: ChatRepository(firebaseService: firebaseService))
                                          )
            ),
            inviteCode: inviteCode,
            otherInviteCode: otherInviteCode)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension LogInCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators.removeAll()
        self.delegate?.didFinish(childCoordinator: self)
    }
}
