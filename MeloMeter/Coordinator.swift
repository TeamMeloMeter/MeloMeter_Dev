//
//  Coordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/15.
//

import UIKit

protocol CoordinatorDelegate: AnyObject {
    
    func didFinish(childCoordinator: Coordinator)
}

protocol Coordinator: AnyObject {
    
    var delegate: CoordinatorDelegate? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    init(_ navigationController: UINavigationController)

    func start()
    func finish()
    func popViewController()
    func dismissViewController()
    func presentErrorAlert(title: String?, message: String?, handler: (() -> Void)?)
}

extension Coordinator {
    
    func finish() {
        childCoordinators.removeAll()
        delegate?.didFinish(childCoordinator: self)
    }
    
    func popViewController() {
        self.navigationController.popViewController(animated: true)
    }
    
    func dismissViewController() {
        navigationController.dismiss(animated: true)
    }
    
    func presentErrorAlert(
        title: String? = nil,
        message: String? = nil,
        handler: (() -> Void)? = nil
    ) {
        //let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //    .appendingAction(title: "확인", handler: handler)
        
        //navigationController.present(alertController, animated: true)
    }
}
