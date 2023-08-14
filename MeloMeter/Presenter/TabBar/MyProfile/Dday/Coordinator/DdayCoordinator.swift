//
//  DdayCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/14.
//

import UIKit
final class DdayCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    weak var parentCoordinator: Coordinator?
    
    init(_ navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        navigationController.navigationBar.standardAppearance = appearance
        
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showDdayVC()
    }

}

extension DdayCoordinator {
    
    func showDdayVC() {
        let viewController = DdayVC(viewModel: DdayVM(coordinator: self,
                                                      dDayUseCase: DdayUseCase(coupleRepository: CoupleRepository(firebaseService: DefaultFirebaseService()))))
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddDdayVC(viewModel: DdayVM) {
        let viewController = AddDdayModal(viewModel: viewModel)
        viewController.modalPresentationStyle = .custom
        self.navigationController.present(viewController, animated: true, completion: nil)
    }
    
    
}
