//
//  AppCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift

public enum AccessLevel: String {
    case none, start, authenticated, coupleCombined, complete
    
    var toString: String {
        switch self {
        case .start:
            return "none"
        case .authenticated:
            return "authenticated"
        case .coupleCombined:
            return "coupleCombined"
        case .complete:
            return "complete"
        default:
            return "none"
        }
    }
}

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
        self.showSplashVC()
    }
    
}

// MARK: - connectFlow Methods
extension AppCoordinator {
    
    func showSplashVC() {
        let splashVC = SplashVC(viewModel: SplashVM(coordinator: self,
                                                   firebaseService: DefaultFirebaseService()))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(splashVC, animated: false)
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
        //self.navigationController.popToRootViewController(animated: true)
        let tabBarCoordinator = TabBarCoordinator(self.navigationController)
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
        print("앱ㅋ코디네이터 didFinish", childCoordinator)
        if childCoordinator is LogInCoordinator {
            if let userName = UserDefaults.standard.string(forKey: "userName") {
                print("앱ㅋ코디네이터 탭바플로우 시작점")
                self.connectTabBarFlow()
            }else {
                self.connectPresetFlow()
            }
        }else if childCoordinator is PresetCoordinator {
            self.connectTabBarFlow()
        }else {
            self.connectLogInFlow()
        }
    }
    
}
