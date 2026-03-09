//
//  BMBDCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public final class HundredCoordinator: Coordinator {
    public var delegate: CoordinatorDelegate?
    
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    private let dependencies: PresentationDependencyProviding
    public let admobRepo = AdmobRepository()
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
    }
    
    public func start() {
        showHundredQAVC()
    }

}

extension HundredCoordinator {
    
    public func showHundredQAVC() {
        let viewController = HundredQAVC(viewModel: HundredQAVM(coordinator: self,
                                                                 hundredQAUseCase: HundredQAUseCase(
                                                                    hundredQARepository: dependencies.makeHundredQARepository()
                                                                 ))
        )
                                                        
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showReadAnswerVC(questionNumber: String, question: String, myAnswerInfo: AnswerModel, otherAnswerInfo: AnswerModel) {
        let viewModel = AnswerVM(coordinator: self,
                                 hundredQAUseCase: HundredQAUseCase(
                                    hundredQARepository: dependencies.makeHundredQARepository()
                                 ),
                                 adMobRepo: admobRepo,
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
