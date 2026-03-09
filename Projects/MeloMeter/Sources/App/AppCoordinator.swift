//
//  AppCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift
#if canImport(Data)
import Data
#endif
#if canImport(Domain)
import Domain
#endif
#if canImport(Presentation)
import Presentation
#endif

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    private let dependencies: PresentationDependencyProviding
    var disposeBag = DisposeBag()
    var accessLevel: AccessLevel = .none
    // MARK: - Initializers
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = AppDependencies()
    }
    
    // MARK: - Methods
    func start() {
        self.showSplashVC()
    }
    
}

// MARK: - Flow Routing
private extension AppCoordinator {
    func route(for accessLevel: AccessLevel) {
        switch accessLevel {
        case .none, .start:
            connectLogInFlow(accessLevel: false)
        case .authenticated:
            connectLogInFlow(accessLevel: true)
        case .coupleCombined:
            connectPresetFlow()
        case .complete:
            connectTabBarFlow()
        }
    }
    
    func routeUsingFirestoreState() {
        dependencies.firebaseService.getCurrentUser()
            .flatMap { [unowned self] user in
                self.dependencies.firebaseService.getDocument(collection: .Users, document: user.uid)
            }
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                let accessLevel = UserDefaultsRepo.shared.persistent(document: data)
                DispatchQueue.main.async {
                    self.route(for: accessLevel)
                }
            }, onFailure: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.connectLogInFlow(accessLevel: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - connectFlow Methods
extension AppCoordinator {
    
    func showSplashVC() {
        let firebaseService = self.dependencies.firebaseService
        let splashVC = SplashVC(
            viewModel: SplashVM(coordinator: self,
                                firebaseService: firebaseService,
                                userRepository: dependencies.makeUserRepository(), adMobRepo: AdmobRepository()
                               )
        )
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(splashVC, animated: false)
    }
    
    func connectLogInFlow(accessLevel: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let logInCoordinator = LogInCoordinator(self.navigationController, dependencies: dependencies)
        logInCoordinator.delegate = self
        logInCoordinator.isLogin = accessLevel
        self.childCoordinators.append(logInCoordinator)
        logInCoordinator.start()
    }

    func connectPresetFlow() {
        self.navigationController.viewControllers.removeAll()
        let presetCoordinator = PresetCoordinator(self.navigationController, dependencies: dependencies)
        presetCoordinator.delegate = self
        presetCoordinator.start()
        self.childCoordinators.append(presetCoordinator)
    }
    
    func connectTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(self.navigationController, dependencies: dependencies)
        tabBarCoordinator.delegate = self
        tabBarCoordinator.start()
        self.childCoordinators.append(tabBarCoordinator)
    }
    

}

// MARK: - Coodinator Delegate
extension AppCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = []
        self.navigationController.viewControllers.removeAll()
        if childCoordinator is LogInCoordinator {
            routeUsingFirestoreState()
        } else if childCoordinator is PresetCoordinator {
            self.connectTabBarFlow()
        } else if childCoordinator is TabBarCoordinator {
            self.showSplashVC()
        } else {
            self.connectLogInFlow()
        }
    }
    
}
