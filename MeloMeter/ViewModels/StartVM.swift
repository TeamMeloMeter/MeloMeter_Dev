//
//  StartVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift
import Firebase

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
                    coordinator.connectLogInFlow()
                }
            }).disposed(by: disposeBag)
    }
    
}
