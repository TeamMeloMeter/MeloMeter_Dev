//
//  ChatCoordinator.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
final class ChatCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    let firebaseService = DefaultFirebaseService()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showChatVC()
    }
    
}

extension ChatCoordinator {
    
    func showChatVC() {
        let firebaseService = self.firebaseService
        let chatRepository = ChatRepository(firebaseService: firebaseService)
        let viewController = DisplayChatVC(
            viewModel: ChatVM(coordinator: self,
                              chatUseCase: ChatUseCase(
                                chatRepository: chatRepository,
                                coupleRepository: CoupleRepository(firebaseService: firebaseService),
                                userRepository: UserRepository(firebaseService: firebaseService, chatRepository: chatRepository)
                              ),
                              hundredQAUseCase: HundredQAUseCase(hundredQARepository:
                                                                    HundredQARepository(firebaseService: firebaseService)
                                                                )
                             )
        )
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHundredQAFlow() {
        let hundredQACoordinator = HundredCoordinator(self.navigationController)
        hundredQACoordinator.delegate = self
        childCoordinators.append(hundredQACoordinator)
        hundredQACoordinator.start()
    }
    
    func showReadAnswerVC(questionNumber: String, question: String, myAnswerInfo: AnswerModel, otherAnswerInfo: AnswerModel) {
        let firebaseService = self.firebaseService
        let hundredQACoordinator = HundredCoordinator(self.navigationController)
        hundredQACoordinator.delegate = self
        childCoordinators.append(hundredQACoordinator)
        let viewModel = AnswerVM(coordinator: hundredQACoordinator,
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
    
    func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
}

extension ChatCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        if childCoordinator is HundredCoordinator {
            self.navigationController.popViewController(animated: true)
            self.childCoordinators.removeLast()
        }else {
            self.childCoordinators = []
            childCoordinator.navigationController.popToRootViewController(animated: true)
        }
    }
}
