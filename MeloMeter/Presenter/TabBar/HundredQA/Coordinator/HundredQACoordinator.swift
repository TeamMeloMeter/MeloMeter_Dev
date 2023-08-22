//
//  BMBDCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit

final class HundredCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    weak var parentCoordinator: Coordinator?
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showHundredQAVC()
    }

}

extension HundredCoordinator {
    
    func showHundredQAVC() {
        let firebaseService = DefaultFirebaseService()
        let viewController = HundredQAVC(viewModel: HundredQAVM(coordinator: self,
                                                                hundredQAUserCase: HundredQAUserCase(coupleRepository: CoupleRepository(
                                                                    firebaseService: firebaseService)
                                                                ))
        )
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showReadAnswerVC() {
        let firebaseService = DefaultFirebaseService()
        let viewController = ReadAnswerVC(viewModel: AnswerVM(coordinator: self,
                                                                hundredQAUserCase: HundredQAUserCase(coupleRepository: CoupleRepository(
                                                                    firebaseService: firebaseService)
                                                                ))
        )
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWriteAnswerVC(question: String, name: String) {
        let firebaseService = DefaultFirebaseService()
        let viewController = WriteAnswerVC(viewModel: AnswerVM(coordinator: self,
                                                                hundredQAUserCase: HundredQAUserCase(coupleRepository: CoupleRepository(
                                                                    firebaseService: firebaseService)
                                                                )
                                                             ),
                                           question: question,
                                           userName: name)
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
}
