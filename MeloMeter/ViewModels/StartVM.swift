//
//  StartVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift

class StartVM {
    
    let fb = DefaultFirebaseService()
    weak var coordinator: AppCoordinator?
    private let disposeBag = DisposeBag()
    // MARK: Input
    var startBtnTab = PublishSubject<Bool>()
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
        startBtnTab
            .subscribe(onNext: { result in
                if result {
                    coordinator.didFinish(childCoordinator: coordinator)
                }
            }).disposed(by: disposeBag)
    }
    
}
