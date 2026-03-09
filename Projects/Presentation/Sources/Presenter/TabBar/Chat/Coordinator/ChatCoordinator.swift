//
//  ChatCoordinator.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif
public final class ChatCoordinator: Coordinator {
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
        showChatVC()
    }
    
}

extension ChatCoordinator {
    
    public func showChatVC() {
        let chatRepository = dependencies.makeChatRepository()
        let viewController = DisplayChatVC(
            viewModel: ChatVM(coordinator: self,
                              chatUseCase: ChatUseCase(
                                chatRepository: chatRepository,
                                coupleRepository: dependencies.makeCoupleRepository(),
                                userRepository: dependencies.makeUserRepository(chatRepository: chatRepository)
                              ),
                              hundredQAUseCase: HundredQAUseCase(hundredQARepository:
                                                                    dependencies.makeHundredQARepository()
                                                                )
                             )
        )
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func showHundredQAFlow() {
        let hundredQACoordinator = HundredCoordinator(self.navigationController, dependencies: dependencies)
        hundredQACoordinator.delegate = self
        childCoordinators.append(hundredQACoordinator)
        hundredQACoordinator.start()
    }
    
    public func showReadAnswerVC(questionNumber: String, question: String, myAnswerInfo: AnswerModel, otherAnswerInfo: AnswerModel) {
        let hundredQACoordinator = HundredCoordinator(self.navigationController, dependencies: dependencies)
        hundredQACoordinator.delegate = self
        childCoordinators.append(hundredQACoordinator)
        let viewModel = AnswerVM(coordinator: hundredQACoordinator,
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
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
}

extension ChatCoordinator: CoordinatorDelegate {
    
    public func didFinish(childCoordinator: Coordinator) {
        if childCoordinator is HundredCoordinator {
            self.navigationController.popViewController(animated: true)
            self.childCoordinators.removeLast()
        }else {
            self.childCoordinators = []
            childCoordinator.navigationController.popToRootViewController(animated: true)
        }
    }
}
