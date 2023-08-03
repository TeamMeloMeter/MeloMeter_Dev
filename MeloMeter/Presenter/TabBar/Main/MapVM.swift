//
//  MapVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit
import RxSwift
import RxRelay
import CoreLocation
import RxCocoa

class MapVM {

    weak var coordinator: MainCoordinator?
    private var mainUseCase: MainUseCase

    struct Input {
        let viewDidApearEvent: Observable<Void>
        let dDayBtnTapEvent: Observable<Void>
        let alarmBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        let showDdayVC: PublishRelay<Bool> = PublishRelay()
        let authorizationAlertShouldShow = BehaviorRelay<Bool>(value: false)
        let currentLocation: BehaviorRelay<CLLocation> = BehaviorRelay(value: CLLocation(latitude: 37.541, longitude: 126.986))
        let currentOtherLocation: BehaviorRelay<CLLocation> = BehaviorRelay(value: CLLocation(latitude: 37.541, longitude: 126.986))
    }
    
    
    init(coordinator: MainCoordinator, mainUseCase: MainUseCase) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidApearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.mainUseCase.checkAuthorization()
                self?.mainUseCase.requestLocation()
                self?.mainUseCase.requestOtherLocation()
            })
            .disposed(by: disposeBag)
        
        input.dDayBtnTapEvent
            .subscribe(onNext: {  }) // 기념일 화면으로 전환하기
            .disposed(by: disposeBag)
        
        input.alarmBtnTapEvent
            .subscribe(onNext: {  }) // 알림 화면으로 전환하기
            .disposed(by: disposeBag)
        
        self.mainUseCase.authorizationStatus
            .map({ $0 == .halfallowed || $0 == .disallowed })
            .bind(to: output.authorizationAlertShouldShow)
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedLocation
            .asObservable()
            .bind(to: output.currentLocation)
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedOtherLocation
            .map{ otherLocation in
                if let location = otherLocation {
                    return location
                }else {
                    return CLLocation(latitude: 37.541, longitude: 126.986)
                }
            }
            .asObservable()
            .bind(to: output.currentOtherLocation)
            .disposed(by: disposeBag)
        
        return output
    }
    
}
