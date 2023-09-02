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
        let firebaseService = DefaultFirebaseService()
        let viewController = DisplayChatVC(
            viewModel: ChatVM(coordinator: self,
                              chatUseCase: ChatUseCase(
                                chatRepository: ChatRepository(firebaseService: firebaseService),
                                coupleRepository: CoupleRepository(firebaseService: firebaseService),
                                userRepository: UserRepository(firebaseService: firebaseService))
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
