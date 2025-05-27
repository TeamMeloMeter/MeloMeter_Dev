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
import GoogleMobileAds
class MapVM {

    weak var coordinator: MainCoordinator?
    private var mainUseCase: MainUseCase
    private var uploadPlaceUseCase: UploadPlaceUseCase
    
    //MARK: Observable
    var pickedModel = BehaviorRelay<SearchedModel?>(value: nil)
    var couplePlaceModel = BehaviorRelay<CouplePlaceModel?>(value: nil)
    var bottomSheetDisappear = PublishSubject<Void>()

    //MARK: StaticDatas
    let categoryLists = ["전체","맛집","전시회","공원","기타"]
    
    func dissmissBottomSheet() {
        pickedModel.accept(nil)
        coordinator?.dismissViewController()
    }
    
    struct BottomSheetInput {
        let dismissBottomSheet: Observable<Void>
        let categoryTapped: Observable<Int?>
        let pictureTapped: Observable<(Int?, Data?)>
        
        let loactionTFtexts: Observable<String>
        let memoTFtexts: Observable<String>
        let viewWillDisappear: Observable<Void>
        let largeSaveBtnTapped: Observable<Void>
    }
    struct BottomSheetOutput {
        var categoryIsSelected = BehaviorRelay<[Bool]>(value: [false, false, false, false, false])
        var pictureValues = BehaviorRelay<[Data]>(value: [])
        var btnEnabled = BehaviorRelay<Bool>(value: false)
    }
    func transform(input: BottomSheetInput, disposeBag: DisposeBag) -> BottomSheetOutput {
        
        let output = BottomSheetOutput()

        Observable.combineLatest(input.loactionTFtexts, input.memoTFtexts, output.categoryIsSelected ,output.pictureValues).map {
            values in
            guard let pickedModel = self.pickedModel.value else {return false}
            
            let model = CouplePlaceModel(category: self.categoryLists[values.2.firstIndex(of: true) ?? 0], name: values.1, description: values.0, mapX: pickedModel.mapx, mapY: pickedModel.mapy, images: values.3, roadAddress: pickedModel.roadAddress, address: pickedModel.address)
            self.couplePlaceModel.accept(model)
            
            return (!values.0.isEmpty && !values.1.isEmpty && values.2.contains(true) )
        }.bind(to: output.btnEnabled).disposed(by: disposeBag)
        
        input.categoryTapped.map({ num in
            guard let num else {return []}
            var arr = [false, false, false, false, false]
            arr[num] = true
            return arr
        }).bind(to: output.categoryIsSelected).disposed(by: disposeBag)
        
        input.pictureTapped.subscribe(onNext: { (idx, data) in
            var beforePictures = output.pictureValues.value
            guard let data else {return}
            if let idx ,beforePictures.count > idx {
                beforePictures[idx] = data
            } else {
                beforePictures.append(data)
            }
            output.pictureValues.accept(beforePictures)
            
        }).disposed(by: disposeBag)
        
        input.dismissBottomSheet.bind(onNext: self.dissmissBottomSheet).disposed(by: disposeBag)
        
        input.viewWillDisappear.map{ self.pickedModel.accept(nil); return () }.bind(to: bottomSheetDisappear).disposed(by: disposeBag)
        
        input.largeSaveBtnTapped.subscribe(onNext: { [weak self] _ in
            
            guard let self, let model = couplePlaceModel.value else {return}

            uploadPlaceUseCase.execute(model: model).subscribe({ com in
                print(com)
            }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        return output
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let dDayBtnTapEvent: Observable<Void>
        let alarmBtnTapEvent: Observable<Void>
        let searchBtnTapEvent: Observable<Void>
        let endTriggerAlertTapEvent: Observable<Void>
        let dissmissBottomSheet: Observable<Void>
        
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
        var getBottomBannerAd = BehaviorSubject<BannerView?>(value: nil)
        var pickerLocations = PublishSubject<[SearchedModel]>()
        var cameraUpdate = PublishSubject<CLLocation>()
        var setUpBottomSheet = PublishSubject<SearchedModel>()
        var deletePickedMarkers = PublishSubject<Void>()
    }
    
    
    init(coordinator: MainCoordinator, mainUseCase: MainUseCase, uploadPlaceUseCase: UploadPlaceUseCase) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        self.uploadPlaceUseCase = uploadPlaceUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        if #available(iOS 16.0, *) {
            Observable.combineLatest(input.viewWillAppear, self.bottomSheetDisappear.startWith(()))
                .subscribe(onNext: { [weak self] _ in
                    guard let self else {return}
                    // 장소 검색 시 잠깐 동안 뜨는 용도의 피커 지움
                    output.deletePickedMarkers.onNext(())
                    
                    if let pickedModel = pickedModel.value {
                        //TODO: 추후 이미 생성된 데이터 마커
                        output.pickerLocations.onNext([pickedModel])
                        coordinator?.setupSheet(pickedModel: pickedModel)
                    }
                    output.getBottomBannerAd.onNext(mainUseCase.getBottomBannerAd())
                    
                    self.mainUseCase.disconnectionObserver()
                        .subscribe(onSuccess: { result in
                            if result {
                                output.endTrigger.onNext(true)
                            }
                        })
                        .disposed(by: disposeBag)
                    
                    setInfo()
                    self.mainUseCase.checkAuthorization()
                    self.mainUseCase.requestLocation()
                    self.mainUseCase.requestOtherLocation()
                    
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
        
        input.searchBtnTapEvent.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            self.coordinator?.pushMapSearchVC()
            
        }).disposed(by: disposeBag)
        
        self.mainUseCase.authorizationStatus
            .map({ $0 == .halfallowed || $0 == .disallowed || $0 == .notDetermined})
            .bind(to: output.authorizationAlertShouldShow)
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedLocation
            .subscribe(onNext: { [weak self] location in
                guard let self else {return}
                
                if let location = location {
                    output.currentLocation.onNext(location)
                    if let model = pickedModel.value {
                        output.cameraUpdate.onNext(CLLocation(latitude: model.mapy, longitude: model.mapx))
                    } else {
                        output.cameraUpdate.onNext(location)
                    }
       
                } else {
                    coordinator?.finish()
                    output.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
                }
            })
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedOtherLocation
            .subscribe(onNext: { otherLocation in
                if let location = otherLocation {
                    output.currentOtherLocation.onNext(location)
                } else {
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
        
        input.dissmissBottomSheet.bind(onNext: self.dissmissBottomSheet).disposed(by: disposeBag)
        
        func setInfo() {
            self.mainUseCase.getUserData()
            self.mainUseCase.userData
                .subscribe(onNext: { userInfo in
                    guard let userInfo else{ return }
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
                                UserDefaults.standard.set(userInfo.coupleID, forKey: "coupleID")
                                
                                
                                
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
