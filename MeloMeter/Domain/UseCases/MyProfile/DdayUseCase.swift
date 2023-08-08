//
//  DdayUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import Firebase

class DdayUseCase {
    
    private var disposeBag: DisposeBag
    private var dDdayRepository: DdayRepository
    private let calendar = Calendar.current
    var firstDay: PublishRelay<Date>
    
    init(dDayRepository: DdayRepository) {
        self.dDdayRepository = dDayRepository
        self.firstDay = PublishRelay()
        self.disposeBag = DisposeBag()
    }
    
    func getFirstDay() {
        self.dDdayRepository.getDdays()
            .subscribe(onSuccess: { dDayModel in
                if let day = dDayModel?.firstDay {
                    self.firstDay.accept(day)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func pmDday(from date: Date) -> Int {
        let result = (calendar.dateComponents([.day], from: Date(), to: date).day ?? 0)
        if result < 0 {
            return  result
        }
        return result
    }
    
}
