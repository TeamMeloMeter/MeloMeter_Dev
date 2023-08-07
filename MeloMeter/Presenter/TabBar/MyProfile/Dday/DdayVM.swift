//
//  DdayVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import UIKit
import RxSwift
import RxRelay

class DdayVM {

    weak var coordinator: MyProfileCoordinator?
    private var dDayUseCase: DdayUseCase

    struct Input {
        //let viewDidApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let addDdayBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var userName = PublishRelay<String>()
        var userPhoneNumber = PublishRelay<String>()
        var stateMessage = PublishRelay<String>()
    }
    
    
    init(coordinator: MyProfileCoordinator, dDayUseCase: DdayUseCase) {
        self.coordinator = coordinator
        self.dDayUseCase = dDayUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                print("뒤로가기 버튼탭")
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
