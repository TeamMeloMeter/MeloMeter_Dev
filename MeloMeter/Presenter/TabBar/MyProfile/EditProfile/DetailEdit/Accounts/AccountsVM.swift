//
//  DisconnectVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/18.
//

import UIKit
import RxSwift
import RxRelay

enum AccountsButton {
    case disconnect, recovery, withdrawal
}

class AccountsVM {

    weak var coordinator: MyProfileCoordinator?
    private var disconnectUseCase: DisconnectUseCase
    
    struct Input {
        let backBtnTapEvent: Observable<Void>
        let excuteBtnEvent: Observable<AccountsButton>
    }
    
    struct Output {
    }
    
    
    init(coordinator: MyProfileCoordinator, disconnectUseCase: DisconnectUseCase) {
        self.coordinator = coordinator
        self.disconnectUseCase = disconnectUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
            input.excuteBtnEvent
                .subscribe(onNext: {[weak self] btnType in
                    guard let self = self else{ return }
                    switch btnType {
                    case .disconnect:
                        self.coordinator?.showRecoveryVC()
                    case .recovery:
                        self.coordinator?.popViewController()
                    case .withdrawal:
                        self.coordinator?.popViewController()
                    }
                    
                })
                .disposed(by: disposeBag)
        
        
        
        return output
    }
    
    
}
