//
//  PermissionVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/26.
//

import UIKit
import RxSwift

class PermissionVM {

    weak var coordinator: LogInCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    var startBtnTapped1 = PublishSubject<Void>()
    var startBtnTapped2 = PublishSubject<Void>()
    
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
        
        startBtnTapped1.subscribe(onNext: {
            coordinator.showPermissionVC2()
        })
        .disposed(by: disposeBag)
        
        startBtnTapped2.subscribe(onNext: {
            coordinator.finish()
        })
        .disposed(by: disposeBag)
    }
    
}
