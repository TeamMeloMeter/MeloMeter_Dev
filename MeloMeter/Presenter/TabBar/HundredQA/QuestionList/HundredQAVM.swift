//
//  HundredQAVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class HundredQAVM {

    weak var coordinator: HundredCoordinator?
    private var hundredQAUserCase: HundredQAUserCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let cellTapEvent: Observable<Int>
    }
    
    struct Output {
       
    }
    
    init(coordinator: HundredCoordinator, hundredQAUserCase: HundredQAUserCase) {
        self.coordinator = coordinator
        self.hundredQAUserCase = hundredQAUserCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
          
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.cellTapEvent
            .subscribe(onNext: {[weak self] index in
                guard let self = self else{ return }
                self.coordinator?.showReadAnswerVC()
            })
            .disposed(by: disposeBag)

        return output
    }
    
}

