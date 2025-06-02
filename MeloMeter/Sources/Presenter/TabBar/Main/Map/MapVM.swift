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
import Kingfisher
class MapVM {

    weak var coordinator: MainCoordinator?
    private var mainUseCase: MainUseCase
    private var placeUseCase: PlaceUseCase
    
    var alreadyPlacesMarkers = PublishSubject<[CouplePlaceModel]>()
    var lastPickedPicker = BehaviorRelay<CouplePlaceModel?>(value: nil)
    var pickedModel = BehaviorRelay<SearchedModel?>(value: nil)
    var bottomSheetDisappear = PublishSubject<Void>()


    //MARK: StaticDatas
    let categoryLists = ["전체","맛집","전시회","공원","기타"]
    
    func dissmissBottomSheet() {
        pickedModel.accept(nil)
//        lastPickedPicker = BehaviorRelay<CouplePlaceModel?>(value: nil)
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
        let editBtnTapped: Observable<Void>
        let deleteBtnTapped: Observable<Void>
        let threeDoutTapped: Observable<Void>
        let informViewTapped: Observable<Void>
        let deletePicker: Observable<Void>
        
    }
    struct BottomSheetOutput {
        var categoryIsSelected = BehaviorRelay<[Bool]>(value: [false, false, false, false, false])
        var pictureValues = BehaviorRelay<[Data]>(value: [])
        var btnEnabled = BehaviorRelay<Bool>(value: false)
        var dropPickerIsHidden = BehaviorRelay<Bool>(value: true)
        var alert = PublishRelay<(String, String)>()
        var changeEditStyle = PublishRelay<CouplePlaceModel>()
    }
    func transform(input: BottomSheetInput, disposeBag: DisposeBag) -> BottomSheetOutput {
        var couplePlaceModel = BehaviorRelay<CouplePlaceModel?>(value: nil)
        let output = BottomSheetOutput()
        input.threeDoutTapped.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.dropPickerIsHidden.accept(false)
        }).disposed(by: disposeBag)
        input.informViewTapped.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.dropPickerIsHidden.accept(true)
        }).disposed(by: disposeBag)
        
        //TODO: 버튼 관련
        input.editBtnTapped.subscribe(onNext: { [weak self] event in
            guard let self, let model = lastPickedPicker.value else {return}
            var datas: [Data] = []
            model.imageURLs?.forEach { url in
                let group = DispatchGroup()
                
                group.enter()
                self.getDataFromURL(url: URL(string: url)!) { data in
                    if let data = data {
                        datas.append(data)
                    }
                    group.leave()
                }
                group.notify(queue: .main) {
                    output.pictureValues.accept(datas)
                }
            }
           
            
            output.changeEditStyle.accept(model)
        }).disposed(by: disposeBag)
        
        input.deleteBtnTapped.bind(onNext: { [weak self] in
            guard let self else {return}
            output.alert.accept(("삭제하기","삭제한 마커는 되돌릴 수 없어요!"))
        }).disposed(by: disposeBag)
        
        input.deletePicker
            .withLatestFrom(lastPickedPicker)
            .compactMap { $0 } // nil 제거
            .flatMap { [weak self] model -> Observable<Void> in
                guard let self else { return .empty() }
                return self.placeUseCase.delPlace(model: model)
                    .andThen(Observable.just(()))
            }.flatMap { [weak self] _ -> Observable<[CouplePlaceModel]> in
                guard let self else {return Observable.empty()}
                return self.placeUseCase.fetchAll().asObservable()
            }
            .subscribe(onNext: { [weak self] places in
                guard let self else {return}
                alreadyPlacesMarkers.onNext(places)
                self.dissmissBottomSheet()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.loactionTFtexts, input.memoTFtexts, output.categoryIsSelected ,output.pictureValues).map { [weak self]
            values in
            guard let self, let pickedModel = pickedModel.value else {return false}
            
            let model = CouplePlaceModel(category: self.categoryLists[values.2.firstIndex(of: true) ?? 0], name: values.1, description: values.0, mapX: pickedModel.mapx, mapY: pickedModel.mapy, roadAddress: pickedModel.roadAddress, address: pickedModel.address, imagesDatas: values.3)
            couplePlaceModel.accept(model)
            
            return (!values.0.isEmpty && !values.1.isEmpty && values.2.contains(true) )
        }.bind(to: output.btnEnabled).disposed(by: disposeBag)
        
        input.categoryTapped.map({ [weak self] num in
            guard let self, let num else {return []}
            var arr = [false, false, false, false, false]
            arr[num] = true
            return arr
        }).bind(to: output.categoryIsSelected).disposed(by: disposeBag)
        
        input.pictureTapped.subscribe(onNext: { [weak self] (idx, data) in
            var beforePictures = output.pictureValues.value
            guard let self, let data else {return}
            if let idx ,beforePictures.count > idx {
                beforePictures[idx] = data
            } else {
                beforePictures.append(data)
            }
            output.pictureValues.accept(beforePictures)
            
        }).disposed(by: disposeBag)
        
        input.dismissBottomSheet.bind(onNext: { [weak self] in
            guard let self else {return}
            self.dissmissBottomSheet()}).disposed(by: disposeBag)
        
        input.viewWillDisappear.map {  [weak self] in guard let self else {return}; pickedModel.accept(nil); return () }.bind(to: bottomSheetDisappear).disposed(by: disposeBag)
        
        input.largeSaveBtnTapped
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self, let model = couplePlaceModel.value else {
                    return Observable.error(NSError(domain: "", code: -1))
                }
                return placeUseCase.upload(model: model).andThen(Observable.just(()))
            }.subscribe(onNext: { [weak self] in
                guard let self else {return}
                placeUseCase.fetchAll().subscribe(onSuccess: { [weak self] places in
                    guard let self else {return}
                    alreadyPlacesMarkers.onNext(places)
                }).disposed(by: disposeBag)
                
                self.dissmissBottomSheet()
            }, onError: { err in
                print(err)
                //TODO: 에러처리
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
        let markerTapped: Observable<CouplePlaceModel>
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
        var searchedMarker = PublishSubject<SearchedModel>()
        var cameraUpdate = PublishSubject<CLLocation>()
        var setUpBottomSheet = PublishSubject<SearchedModel>()
        var deletePickedMarkers = PublishSubject<Void>()
        var alreadyPlacesMarkers = PublishSubject<[CouplePlaceModel]>()
    }
    
    
    init(coordinator: MainCoordinator, mainUseCase: MainUseCase, uploadPlaceUseCase: PlaceUseCase) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        self.placeUseCase = uploadPlaceUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(alreadyPlacesMarkers: alreadyPlacesMarkers)
        
        input.markerTapped.subscribe(onNext: { [weak self] model in
            guard let self else {return}
            lastPickedPicker.accept(model)
            self.coordinator?.setupSheet(pickedModel: nil, placeModel: model, type: "inform")
        }).disposed(by: disposeBag)
        
        self.bottomSheetDisappear.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.deletePickedMarkers.onNext(())
        }).disposed(by: disposeBag)

        if #available(iOS 16.0, *) {
            input.viewWillAppear
                .subscribe(onNext: { [weak self] _ in
                    guard let self else {return}
                    // 장소 검색 시 잠깐 동안 뜨는 용도의 피커 지움
                    if let pickedModel = pickedModel.value {
                        output.searchedMarker.onNext(pickedModel)
                        coordinator?.setupSheet(pickedModel: pickedModel, placeModel: nil, type: "small")                    }
                    placeUseCase.fetchAll().subscribe({ [weak self] single in
                        guard let self else {return}
                        switch single {
                        case .success(let places):
                            output.alreadyPlacesMarkers.onNext(places)
                        case .failure(_): break
                            //TODO: Error Alert
                        }
                    }).disposed(by: disposeBag)
                    
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
extension MapVM {
    func getDataFromURL(url: URL, completion: @escaping (Data?) -> Void) {
        ImageDownloader.default.downloadImage(with: url, completionHandler:  { result in
            switch result {
            case .success(let response):
                completion(response.originalData)
            case .failure(let error):
                break
            }
        })
    }
}
