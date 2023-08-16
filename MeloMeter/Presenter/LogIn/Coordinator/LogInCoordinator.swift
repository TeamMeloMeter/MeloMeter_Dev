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
            showPhoneCertifiedVC()
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
    func showPhoneCertifiedVC() {
        let viewController = PhoneCertifiedVC(
            viewModel: LogInVM(
                coordinator: self,
                logInUseCase: LogInUseCase(logInRepository: LogInRepository(firebaseService: firebaseService),
                                           userRepository: UserRepository(firebaseService: firebaseService))
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAuthNumVC(phoneNumber: String?) {
        let viewModel = LogInVM(
            coordinator: self,
            logInUseCase: LogInUseCase(logInRepository: LogInRepository(firebaseService: firebaseService),
                                       userRepository: UserRepository(firebaseService: firebaseService)
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
                                           userRepository: UserRepository(firebaseService: firebaseService)
                                          )
            ),
            inviteCode: inviteCode,
            otherInviteCode: otherInviteCode)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        print("로그인코디finish")
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

extension LogInCoordinator: CoordinatorDelegate {
    func didFinish(childCoordinator: Coordinator) {
        print("로그인코디Didfinish")
        self.childCoordinators.removeAll()
        self.delegate?.didFinish(childCoordinator: self)
    }
}
