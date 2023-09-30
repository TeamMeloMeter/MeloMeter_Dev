//
//  AlarmVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/21.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class AlarmVM {

    weak var coordinator: AlarmCoordinator?
    private var alarmUseCase: AlarmUseCase
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
    }
    
    struct Output {

    }
    
    init(coordinator: AlarmCoordinator, alarmUseCase: AlarmUseCase) {
        self.alarmUseCase = alarmUseCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.alarmUseCase.getAlarmService().subscribe( onSuccess: { Element in
                    print("🟢",Element)
                })
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
}
