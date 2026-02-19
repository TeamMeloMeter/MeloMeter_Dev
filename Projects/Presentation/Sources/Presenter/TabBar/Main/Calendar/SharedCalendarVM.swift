//
//  SharedCalendarVM.swift
//  Presentation
//
//  Created by OpenCode on 2026/01/14.
//

import Foundation
import RxSwift
import RxCocoa
import Domain

public final class SharedCalendarVM {
    public struct Input {
        let viewWillAppear: Observable<Void>
        let dateSelected: Observable<DateComponents>
        let addBtnTap: Observable<Void>
        let savePlan: Observable<DatePlanModel>
    }
    
    public struct Output {
        let allPlans: Driver<[DatePlanModel]>
        let currentDayPlans: Driver<[DatePlanModel]>
        let navigateToAdd: Signal<DateComponents>
        let planSaved: Signal<Void>
    }
    
    private let useCase: DatePlanUseCase
    private let disposeBag = DisposeBag()
    
    public init(useCase: DatePlanUseCase) {
        self.useCase = useCase
    }
    
    public func transform(input: Input) -> Output {
        let allPlansRelay = BehaviorRelay<[DatePlanModel]>(value: [])
        let selectedDateRelay = BehaviorRelay<DateComponents?>(value: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        
        // Fetch Plans
        input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<[DatePlanModel]> in
                guard let self = self else { return Observable.just([]) }
                return self.useCase.observePlans()
            }
            .bind(to: allPlansRelay)
            .disposed(by: disposeBag)
        
        // Date Selection
        input.dateSelected
            .bind(to: selectedDateRelay)
            .disposed(by: disposeBag)
        
        // Current Day Plans
        let currentDayPlans = Observable.combineLatest(allPlansRelay, selectedDateRelay)
            .map { plans, dateComponents -> [DatePlanModel] in
                guard let components = dateComponents,
                      let selectedDate = Calendar.current.date(from: components) else { return [] }
                
                return plans.filter { plan in
                    guard let planDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) else { return false }
                    return Calendar.current.isDate(planDate, inSameDayAs: selectedDate)
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        let navigateToAdd = input.addBtnTap
            .withLatestFrom(selectedDateRelay)
            .map { $0 ?? Calendar.current.dateComponents([.year, .month, .day], from: Date()) }
            .asSignal(onErrorSignalWith: .empty())
            
        let planSaved = input.savePlan
            .flatMap { [weak self] plan -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                return self.useCase.savePlan(model: plan)
                    .andThen(Observable.just(()))
                    .catch { error in
                        print("Failed to save plan: \(error)")
                        return Observable.empty()
                    }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            allPlans: allPlansRelay.asDriver(),
            currentDayPlans: currentDayPlans,
            navigateToAdd: navigateToAdd,
            planSaved: planSaved
        )
    }
}
