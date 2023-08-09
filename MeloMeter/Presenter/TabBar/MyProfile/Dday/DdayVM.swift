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

struct DdayCell {
    var dateName: String
    var date: String
    var countDdays: String
}

class DdayVM {

    weak var coordinator: MyProfileCoordinator?
    private var dDayUseCase: DdayUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let addDdayBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var firstDay: BehaviorRelay<String> = BehaviorRelay(value: "20??.??.??")
        var sinceFirstDay: BehaviorRelay<String> = BehaviorRelay(value: "1일")
        var dDayCellData: BehaviorRelay<[DdayCell]> = BehaviorRelay(value: [])
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
                self.dDayUseCase.createAnniArray()
            })
            .disposed(by: disposeBag)
        
        self.dDayUseCase.firstDay
            .map{ day -> String in
                return "첫 만남 \(day.toString(type: .yearToDay))"
            }
            .asObservable()
            .bind(to: output.firstDay)
            .disposed(by: disposeBag)
        
        self.dDayUseCase.firstDay
            .map{ day -> String in
                return "\(abs(self.dDayUseCase.sinceDday(from: day)))일"
            }
            .asObservable()
            .bind(to: output.sinceFirstDay)
            .disposed(by: disposeBag)
        
        self.dDayUseCase.dDayCellArray
            .map{ data -> [DdayCell] in
                return data.map{ DdayCell(dateName: $0.dateName, date: $0.date.toString(type: .yearToDay), countDdays: $0.countDdays)}
            }
            .asObservable()
            .bind(to: output.dDayCellData)
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
