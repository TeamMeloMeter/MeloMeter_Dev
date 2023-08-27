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

    weak var coordinator: DdayCoordinator?
    private var dDayUseCase: DdayUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let addDdayBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var firstDay: BehaviorRelay<String> = BehaviorRelay(value: "")
        var sinceFirstDay: BehaviorRelay<String> = BehaviorRelay(value: "")
        var dDayCellData: BehaviorRelay<[DdayCell]> = BehaviorRelay(value: [])
        var cellIndexPath: PublishSubject<IndexPath> = PublishSubject()
    }
    
    struct AddDdayInput {
        let xBtnTapEvent: Observable<Void>
        let addDday: Observable<[String]>
    }
    
    init(coordinator: DdayCoordinator, dDayUseCase: DdayUseCase) {
        self.coordinator = coordinator
        self.dDayUseCase = dDayUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.dDayUseCase.coupleObserverExcute()
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
            
        self.dDayUseCase.firstDay
            .map{ day -> String in
                return "\(abs(self.dDayUseCase.sinceDday(from: day)))일"
            }
            .asObservable()
            .bind(to: output.sinceFirstDay)
            .disposed(by: disposeBag)
        
        self.dDayUseCase.dDayCellArray
            .map{ data -> [DdayCell] in
                let result = data.map{ DdayCell(dateName: $0.dateName,
                                                date: $0.date.toString(type: .yearToDay),
                                                countDdays: $0.countDdays)
                }
                self.focusCell(result)
                    .asObservable()
                    .bind(to: output.cellIndexPath)
                    .disposed(by: disposeBag)
                return result
            }
            .asObservable()
            .bind(to: output.dDayCellData)
            .disposed(by: disposeBag)
        
        input.addDdayBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showAddDdayVC(viewModel: self)
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                print("ddaty", self.coordinator)
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    func focusCell(_ cellData: [DdayCell]) -> Single<IndexPath> {
        return Single.create{ single in
            var indexPath = IndexPath(row: 0, section: 0)
            guard let index = cellData.enumerated().min(by: {
                abs(Date.fromStringOrNow($0.element.date, .yearToDay).timeIntervalSinceNow) < abs(Date.fromStringOrNow($1.element.date, .yearToDay).timeIntervalSinceNow)
            })?.offset else {
                single(.success(indexPath))
                return Disposables.create()
            }
            
            indexPath = IndexPath(row: index, section: 0)
            single(.success(indexPath))
            return Disposables.create()
        }
        
    }
    
    func addDdayBinding(input: AddDdayInput, disposeBag: DisposeBag) {
        
        input.xBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.dismissViewController()
            })
            .disposed(by: disposeBag)
        
        input.addDday
            .subscribe(onNext: {[weak self] addDday in
                guard !addDday.isEmpty else{ return }
                self?.dDayUseCase.addDday(add: addDday)
                    .subscribe(onSuccess: {
                        self?.coordinator?.dismissViewController()
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
}
