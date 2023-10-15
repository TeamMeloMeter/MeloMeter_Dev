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
    let firebaseService = DefaultFirebaseService()
    
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
        let firebaseService = self.firebaseService
        let viewController = HundredQAVC(viewModel: HundredQAVM(coordinator: self,
                                                                hundredQAUseCase: HundredQAUseCase(hundredQARepository: HundredQARepository(
                                                                    firebaseService: firebaseService)
                                                                ))
        )
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showReadAnswerVC(questionNumber: String, question: String, myAnswerInfo: AnswerModel, otherAnswerInfo: AnswerModel) {
        let firebaseService = self.firebaseService
        let viewModel = AnswerVM(coordinator: self,
                                 hundredQAUseCase: HundredQAUseCase(hundredQARepository: HundredQARepository(
                                     firebaseService: firebaseService)
                                 ),
                                 questionNumber: questionNumber,
                                 questionText: question,
                                 myAnswerInfo: myAnswerInfo,
                                 otherAnswerInfo: otherAnswerInfo
                              )
        let viewController = ReadAnswerVC(viewModel: viewModel)
                
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWriteAnswerVC(viewModel: AnswerVM) {
        let viewController = WriteAnswerVC(viewModel: viewModel)


        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}
