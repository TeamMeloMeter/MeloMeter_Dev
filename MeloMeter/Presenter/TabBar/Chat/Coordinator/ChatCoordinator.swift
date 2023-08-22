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
            viewModel: ChatVM(coordinator: self, chatUseCase: ChatUseCase(chatRepository: ChatRepository(firebaseService: firebaseService), coupleRepository: CoupleRepository(firebaseService: firebaseService))
                             )
        )
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    
}
