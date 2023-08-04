//
//  MyProfileVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MyProfileVM {

    weak var coordinator: MyProfileCoordinator?
    private var myProfileUseCase: MyProfileUseCase

    struct Input {
        let viewDidApearEvent: Observable<Void>
        
    }
    
    struct Output {
        var userName = PublishRelay<String>()
        var userPhoneNumber = PublishRelay<String>()
        var stateMessage = PublishRelay<String>()
    }
    
    
    init(coordinator: MyProfileCoordinator, myProfileUseCase: MyProfileUseCase) {
        self.coordinator = coordinator
        self.myProfileUseCase = myProfileUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.viewDidApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.myProfileUseCase.getUserInfo()
                    .subscribe(onNext: { user in
                        if let name = user.name, let phoneNumber = user.phoneNumber, let stateMessage = user.stateMessage {
                            output.userName.accept(name)
                            var number = phoneNumber.map{ String($0) }
                            number.insert(" 0", at: 3)
                            number.insert("-", at: 6)
                            number.insert("-", at: 11)
                            output.userPhoneNumber.accept(number.joined())
                            output.stateMessage.accept(stateMessage)
                        }
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
