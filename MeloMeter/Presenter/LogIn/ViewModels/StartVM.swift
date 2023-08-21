//
//  StartVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/16.
//

import UIKit
import RxSwift

class StartVM {
    
    weak var coordinator: LogInCoordinator?
    private let disposeBag = DisposeBag()
    // MARK: Input
    var startBtnTab = PublishSubject<Bool>()
    
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
        
        startBtnTab
            .subscribe(onNext: { result in
                if result {
                    self.coordinator?.showPhoneCertifiedVC()
                }
            }).disposed(by: disposeBag)
    }
    
}
