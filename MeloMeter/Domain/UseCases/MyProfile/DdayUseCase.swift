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
    private var coupleRepository: CoupleRepository
    private let calendar = Calendar.current
    var firstDay: PublishRelay<Date>
    
    init(coupleRepository: CoupleRepository) {
        self.coupleRepository = coupleRepository
        self.firstDay = PublishRelay()
        self.disposeBag = DisposeBag()
    }
    
    func getFirstDay() {
        self.coupleRepository.getCoupleModel()
            .subscribe(onSuccess: { data in
                if let day = data?.firstDay {
                    self.firstDay.accept(day)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func sinceDday(from date: Date) -> String {
        let result = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        print("유케:", date, result)
        return result < 0 ? "\(abs(result))일 지남" : "\(result + 1)일"
    }
    
}
