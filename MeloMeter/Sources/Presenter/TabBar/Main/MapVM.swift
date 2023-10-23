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
        let endTriggerAlertTapEvent: Observable<Void>
    }
    
    struct Output {
        var daySince = PublishSubject<String?>()
        var myProfileImage = PublishSubject<UIImage?>()
        var otherProfileImage = PublishSubject<UIImage?>()
        var myStateMessage = PublishSubject<String?>()
        var otherStateMessage = PublishSubject<String?>()
        var authorizationAlertShouldShow = PublishSubject<Bool>()
        var currentLocation = PublishSubject<CLLocation?>()
        var currentOtherLocation = PublishSubject<CLLocation?>()
        var endTrigger = PublishSubject<Bool>()
    }
    
    
    init(coordinator: MainCoordinator, mainUseCase: MainUseCase) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        if #available(iOS 16.0, *) {
            input.viewWillApearEvent
                .subscribe(onNext: { [weak self] _ in
                    self?.mainUseCase.disconnectionObserver()
                        .subscribe(onSuccess: { result in
                            if result {
                                output.endTrigger.onNext(true)
                            }
                        })
                        .disposed(by: disposeBag)
                    setInfo()
                    self?.mainUseCase.checkAuthorization()
                    self?.mainUseCase.requestAuthorization()
                    self?.mainUseCase.requestLocation()
                    self?.mainUseCase.requestOtherLocation()
                    
                    //잔여 알림 가져오기
                    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                        DispatchQueue.main.sync {
                            
                            for item in notifications {
//                                print("읽지않은 노티 : ",item.request.content.body)
                                let userInfo = item.request.content.userInfo
                                let date = Date().toString(type: .yearToDay)
                                let text = item.request.content.body
                                if let type = userInfo["type"] { PushNotificationService.shared.addAlarm(text: text, date: date, type: type as! String )
                                }
                            }
                        }
                    }
      
                    //잔여 알림목록 초기화
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().setBadgeCount(0)
    
                })
                .disposed(by: disposeBag)
        } else {
            // Fallback on earlier versions
        }
        
        input.dDayBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showDdayFlow()
            })
            .disposed(by: disposeBag)
        
        input.alarmBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showAlarmFlow()
            }) 
            .disposed(by: disposeBag)
        
        self.mainUseCase.authorizationStatus
            .map({ $0 == .halfallowed || $0 == .disallowed || $0 == .notDetermined})
            .bind(to: output.authorizationAlertShouldShow)
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedLocation
            .subscribe(onNext: { location in
                if let location = location {
                    output.currentLocation.onNext(location)
                }else {
                    output.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
                }
            })
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedOtherLocation
            .subscribe(onNext: { otherLocation in
                if let location = otherLocation {
                    output.currentOtherLocation.onNext(location)
                }else {
                    output.currentOtherLocation.onNext(CLLocation(latitude: 0, longitude: 0))
                }
            })
            .disposed(by: disposeBag)
        
        input.endTriggerAlertTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.mainUseCase.excuteRemoveData()
                    .subscribe(onSuccess: {
                        self.coordinator?.finish()
                    }, onFailure: { error in
                        self.coordinator?.finish()
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        func setInfo() {
            self.mainUseCase.getUserData()
            self.mainUseCase.userData
                .subscribe(onNext: { userInfo in
                    guard let userInfo = userInfo else{ return }
                    output.myStateMessage.onNext(userInfo.stateMessage ?? nil)
                    self.mainUseCase.getMyProfileImage(url: userInfo.profileImage ?? "")
                        .subscribe(onSuccess: { image in
                            output.myProfileImage.onNext(image)
                        })
                        .disposed(by: disposeBag)
                    if let otherUid = userInfo.otherUid {
                        self.mainUseCase.getOtherUserData(uid: otherUid)
                        self.mainUseCase.otherUserData
                            .bind(onNext: { otherUserModel in
                                guard let otherUserModel = otherUserModel else{
                                    output.endTrigger.onNext(true)
                                    return
                                }
                                UserDefaults.standard.set(otherUid, forKey: "otherUid")
                                UserDefaults.standard.set(otherUserModel.name, forKey: "otherUserName")
                                UserDefaults.standard.set(otherUserModel.fcmToken, forKey: "otherFcmToken")
                                UserDefaults.standard.set(userInfo.coupleID, forKey: "coupleDocumentID")
                                
                                output.otherStateMessage.onNext(otherUserModel.stateMessage ?? nil)
                            })
                            .disposed(by: disposeBag)
                        self.mainUseCase.getOtherProfileImage(otherUid: otherUid)
                            .subscribe(onSuccess: { image in
                                output.otherProfileImage.onNext(image)
                            })
                            .disposed(by: disposeBag)
                    }
                    
                    self.mainUseCase.getSinceFirstDay(coupleID: userInfo.coupleID ?? "")
                        .subscribe(onSuccess: { date in
                            output.daySince.onNext("D+\(date)")
                        })
                        .disposed(by: disposeBag)
                    
                }, onError: { error in
                    output.endTrigger.onNext(true)
                })
                .disposed(by: disposeBag)
        }
        
        return output
    }
    
    
}
