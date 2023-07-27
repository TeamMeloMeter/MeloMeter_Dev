//
//  LogInCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
final class LogInCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var inviteCode2: String?
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        guard let logInLevel = UserDefaults.standard.string(forKey: "logInLevel") else{ showPhoneCertifiedVC(); return }// 스플래시뷰 만들면 스타트뷰를 예외처리로 넣기
        
        switch logInLevel {
        case "0":
            showPhoneCertifiedVC()
        case "1":
            if let inviteCode = UserDefaults.standard.string(forKey: "inviteCode") {
                let code = "\(inviteCode.prefix(4)) \(inviteCode.suffix(4))"
                if let code2 = inviteCode2 {
                    showCoupleComvineVC(inviteCode: code, inviteCode2: code2)
                }else {
                    showCoupleComvineVC(inviteCode: code)
                }
            }
        case "2":
            showProfileInsertVC()
        case "3":
            showPermissionVC1()
        default:
            showPhoneCertifiedVC()
        }

    }

}

extension LogInCoordinator {
    
    func showPhoneCertifiedVC() {
        let viewController = PhoneCertifiedVC(viewModel: LogInVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAuthNumVC(phoneNumber: String?) {
        let viewModel = LogInVM(coordinator: self)
        viewModel.phoneNumber = phoneNumber
        let viewController = AuthNumVC(viewModel: viewModel)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCoupleComvineVC(inviteCode: String, inviteCode2: String? = nil) {
        let viewController = CoupleCombineVC(viewModel: LogInVM(coordinator: self), inviteCode: inviteCode, inviteCode2: inviteCode2)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfileInsertVC() {
        let viewController = ProfileInsertVC(viewModel: ProfileInsertVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC1() {
        let viewController = PermissionVC(viewModel: PermissionVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPermissionVC2() {
        let viewController = Permission2VC(viewModel: PermissionVM(coordinator: self))
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

}
