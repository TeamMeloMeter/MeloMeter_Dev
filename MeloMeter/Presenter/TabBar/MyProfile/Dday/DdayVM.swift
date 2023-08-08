//
//  DdayVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class DdayVM {

    weak var coordinator: MyProfileCoordinator?
    private var dDayUseCase: DdayUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let addDdayBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var firstDay: BehaviorRelay<String> = BehaviorRelay(value: "2023.00.00")
    }
    
    
    init(coordinator: MyProfileCoordinator, dDayUseCase: DdayUseCase) {
        self.coordinator = coordinator
        self.dDayUseCase = dDayUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.dDayUseCase.getFirstDay()
            })
            .disposed(by: disposeBag)
        
        self.dDayUseCase.firstDay
            .map{ day -> String in
                return "첫 만남 \(day.toString(type: .yearToDay))"
            }
            .asObservable()
            .bind(to: output.firstDay)
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
    
}
