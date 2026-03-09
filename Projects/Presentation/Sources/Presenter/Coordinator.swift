//
//  Coordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/15.
//

import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public protocol CoordinatorDelegate: AnyObject {
    func didFinish(childCoordinator: Coordinator)
}

public protocol Coordinator: AnyObject {
    
    var delegate: CoordinatorDelegate? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    func finish()
    func popViewController()
    func dismissViewController()
}

extension Coordinator {
    
    public func finish() {
        childCoordinators.removeAll()
        delegate?.didFinish(childCoordinator: self)
    }
    
    public func popViewController() {
        self.navigationController.popViewController(animated: true)
    }
    
    public func dismissViewController() {
        navigationController.dismiss(animated: true)
    }
    
}
