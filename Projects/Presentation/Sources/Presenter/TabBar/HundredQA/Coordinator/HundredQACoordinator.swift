//
//  BMBDCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import Domain
import Data
import Core

public final class HundredCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    public let firebaseService = DefaultFirebaseService()
    public let admobRepo = AdmobRepository()
    
    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    public func start() {
        showHundredQAVC()
    }

}

extension HundredCoordinator {
    
    public func showHundredQAVC() {
        let firebaseService = self.firebaseService
        let viewController = HundredQAVC(viewModel: HundredQAVM(coordinator: self,
                                                                hundredQAUseCase: HundredQAUseCase(hundredQARepository: HundredQARepository(
                                                                    firebaseService: firebaseService), admobRepo: admobRepo
                                                                ))
        )
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showReadAnswerVC(questionNumber: String, question: String, myAnswerInfo: AnswerModel, otherAnswerInfo: AnswerModel) {
        let firebaseService = self.firebaseService
        let viewModel = AnswerVM(coordinator: self,
                                 hundredQAUseCase: HundredQAUseCase(hundredQARepository: HundredQARepository(
                                    firebaseService: firebaseService), admobRepo: admobRepo
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
    
    public func showWriteAnswerVC(viewModel: AnswerVM) {
        let viewController = WriteAnswerVC(viewModel: viewModel)


        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    
}
