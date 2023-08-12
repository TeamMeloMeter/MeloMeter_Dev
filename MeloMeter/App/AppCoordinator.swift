//
//  AppCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var firebaseService: FireStoreService
    var disposeBag = DisposeBag()
    // MARK: - Initializers
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.firebaseService = DefaultFirebaseService()
    }
    
    // MARK: - Methods
    func start() {
        // 스플래시뷰 구현하고 스플래시 동작 중에 실행하고, 완료되면 화면전환하게 바꾸기
        selectStartView()
            .subscribe(onSuccess: { state in
                switch state {
                case "NO":
                    self.showStartVC()
                case "Authenticated":
                    self.connectLogInFlow(accessLevel: true)
                case "CoupleCombined":
                    self.connectPresetFlow()
                case "Complete":
                    self.connectTabBarFlow()
                default:
                    self.showStartVC()
                }
            }, onFailure: { _ in
                self.showStartVC()
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: - connectFlow Methods
extension AppCoordinator {
    func selectStartView() -> Single<String> {
        return Single.create { single in
            self.firebaseService.getCurrentUser()
                .subscribe(onSuccess: { user in
                    self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .subscribe(onSuccess: { data in
                            guard let accessLevel = data["accessLevel"] as? String else{ single(.success("NO")); return}
                            single(.success(accessLevel))
                        }, onFailure: { _ in
                            single(.success("NO"))
                        })
                        .disposed(by: self.disposeBag)
                }, onFailure: { _ in
                    single(.success("NO"))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func showStartVC() {
        let startVC = StartVC(viewModel: StartVM(coordinator: self))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(startVC, animated: false)
    }
    
    func connectLogInFlow(accessLevel: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let logInCoordinator = LogInCoordinator(self.navigationController)
        logInCoordinator.delegate = self
        logInCoordinator.isLogin = accessLevel
        logInCoordinator.start()
        self.childCoordinators.append(logInCoordinator)
    }

    func connectPresetFlow() {
        self.navigationController.viewControllers.removeAll()
        let presetCoordinator = PresetCoordinator(self.navigationController)
        presetCoordinator.delegate = self
        presetCoordinator.start()
        self.childCoordinators.append(presetCoordinator)
    }
    
    func connectTabBarFlow() {
        self.navigationController.popToRootViewController(animated: true)
        let tabBarCoordinator = TabBarCoordinator(self.navigationController)
        tabBarCoordinator.delegate = self
        tabBarCoordinator.start()
        self.childCoordinators.append(tabBarCoordinator)
    }
    

}

// MARK: - Coodinator Delegate
extension AppCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        self.navigationController.popToRootViewController(animated: true)
        if childCoordinator is LogInCoordinator {
            self.connectPresetFlow()
        }else if childCoordinator is PresetCoordinator {
            self.connectTabBarFlow()
        }else {
            self.connectLogInFlow()
        }
    }
    
}
