//
//  LogInCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift
import Domain
import Core
public final class LogInCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    private let dependencies: PresentationDependencyProviding
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    public let disposeBag = DisposeBag()
    public var isLogin: Bool = false
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
    }
    
    public func start() {
        if !isLogin {
            showStartVC()
        } else {
            if let inviteCode = UserDefaults.standard.string(forKey: "inviteCode") {
                let code = "\(inviteCode.prefix(4)) \(inviteCode.suffix(4))"
                if let otherInviteCode = UserDefaults.standard.string(forKey: "otherInviteCode") {
                    showCoupleCombineVC(inviteCode: code, otherInviteCode: otherInviteCode)
                } else {
                    showCoupleCombineVC(inviteCode: code)
                }
            } else {
                self.dependencies.firebaseService.getCurrentUser()
                    .subscribe(onSuccess: {[weak self] user in
                        guard let self = self else{ return }
                        self.dependencies.firebaseService.getDocument(collection: .Users, document: user.uid)
                            .subscribe(onSuccess: {[weak self] userInfo in
                                guard let self else {return}
                                
                                if let phoneNumber = userInfo["phoneNumber"] as? String, let currentPhoneNumber = user.phoneNumber {
                                    if phoneNumber.isEmpty {
                                        dependencies.firebaseService.updateDocument(collection: .Users, document: user.uid, values: ["phoneNumber": currentPhoneNumber]).subscribe({ single in
                                            switch single {
                                            case .success(_):
                                                break
                                            case .failure(_):
                                                break
                                            }
                                        }).disposed(by: self.disposeBag)
                                    }
                                }
                                
                                
                                
                                if let inviteCode = userInfo["inviteCode"] as? String {
                                    showCoupleCombineVC(inviteCode: inviteCode)
                                }else {
                                    showStartVC()
                                }
                            }, onFailure: { error in
                                self.showStartVC()
                            })
                            .disposed(by: disposeBag)
                    }, onFailure: { error in
                        self.showStartVC()
                    })
                    .disposed(by: disposeBag)
            }
        }

    }

}

extension LogInCoordinator {
    public func showStartVC() {
        let startVC = StartVC(viewModel: StartVM(coordinator: self))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(startVC, animated: false)
    }
    
    public func showPhoneCertifiedVC() {
        let viewController = PhoneCertifiedVC(
            viewModel: LogInVM(
                coordinator: self,
                logInUseCase: makeLogInUseCase(),
                kakaoShareService: dependencies.kakaoShareService
            )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showAuthNumVC(phoneNumber: String?) {
        let viewModel = LogInVM(
            coordinator: self,
            logInUseCase: makeLogInUseCase(),
            kakaoShareService: dependencies.kakaoShareService
        )
        viewModel.phoneNumber = phoneNumber
        let viewController = AuthNumVC(viewModel: viewModel)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showCoupleCombineVC(inviteCode: String, otherInviteCode: String? = nil) {
        let viewController = CoupleCombineVC(
            viewModel: LogInVM(
                coordinator: self,
                logInUseCase: makeLogInUseCase(),
                kakaoShareService: dependencies.kakaoShareService
            ),
            inviteCode: inviteCode,
            otherInviteCode: otherInviteCode)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}

private extension LogInCoordinator {
    func makeLogInUseCase() -> LogInUseCase {
        return LogInUseCase(
            logInRepository: dependencies.makeLogInRepository(),
            userRepository: dependencies.makeUserRepository()
        )
    }
}

extension LogInCoordinator: CoordinatorDelegate {
    public func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators.removeAll()
        self.delegate?.didFinish(childCoordinator: self)
    }
}
