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
        let viewWillApearEvent: Observable<Void>
        let dDayBtnTapEvent: Observable<Void>
        let alarmBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var daySince = PublishRelay<String>()
        var myProfileImage = PublishRelay<UIImage?>()
        var otherProfileImage = PublishRelay<UIImage?>()
        var myStateMessage =  PublishRelay<String?>()
        var otherStateMessage =  PublishRelay<String?>()
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
        
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                setInfo()
                self?.mainUseCase.requestAuthorization()
                self?.mainUseCase.checkAuthorization()
                self?.mainUseCase.requestLocation()
                self?.mainUseCase.requestOtherLocation()
            })
            .disposed(by: disposeBag)
        
        input.dDayBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showDdayFlow()
            })
            .disposed(by: disposeBag)
        
        input.alarmBtnTapEvent
            .subscribe(onNext: {  }) // 알림 화면으로 전환하기
            .disposed(by: disposeBag)
        
        self.mainUseCase.authorizationStatus
            .map({ $0 == .halfallowed || $0 == .disallowed || $0 == .notDetermined})
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
        
        func setInfo() {
            self.mainUseCase.getUserData()
            self.mainUseCase.userData
                .bind(onNext: { userInfo in
                    output.myStateMessage.accept(userInfo.stateMessage)
                    self.mainUseCase.getMyProfileImage(url: userInfo.profileImage ?? "")
                        .subscribe(onSuccess: { image in
                            output.myProfileImage.accept(image)
                        })
                        .disposed(by: disposeBag)
                    if let otherUid = userInfo.otherUid {
                        self.mainUseCase.getOtherUserData(uid: otherUid)
                        self.mainUseCase.otherUserData
                            .bind(onNext: { otherUserModel in
                                output.otherStateMessage.accept(otherUserModel.stateMessage ?? nil)
                            })
                            .disposed(by: disposeBag)
                        self.mainUseCase.getOtherProfileImage(otherUid: otherUid)
                            .subscribe(onSuccess: { image in
                                output.otherProfileImage.accept(image)
                            })
                            .disposed(by: disposeBag)
                    }
                    
                    self.mainUseCase.getSinceFirstDay(coupleID: userInfo.coupleID ?? "")
                        .subscribe(onSuccess: { date in
                            output.daySince.accept("D+\(date)")
                        })
                        .disposed(by: disposeBag)
                    
                })
                .disposed(by: disposeBag)
        }
        
        return output
    }
    
    
}
