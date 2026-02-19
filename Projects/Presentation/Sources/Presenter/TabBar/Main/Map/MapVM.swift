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
import Domain

public enum MapMode {
    case record
    case reservation
}

public struct DatePlanDraft {
    public let name: String
    public let memo: String
    public let mapX: Double
    public let mapY: Double
    public let roadAddress: String
    public let address: String
    public let scheduledAt: Date
    public let notifyEnabled: Bool
}

public struct CheckInResult {
    public let planId: String
    public let shouldShowRoulette: Bool
}
public class MapVM {

    weak var coordinator: MainCoordinator?
    private var mainUseCase: MainUseCase
    private let adMobRepo: AdmobRepository
    private var placeUseCase: PlaceUseCase
    private var datePlanUseCase: DatePlanUseCase
    private let pushNotificationService: PushNotificationServiceP
    private var currentDatePlans: [DatePlanModel] = []
    private var lastKnownLocation: CLLocation?
    private let arrivalPlanSave = PublishSubject<DatePlanModel>()
    private let defaultPlanRadiusMeters: Double = {
#if DEBUG
        return 1000
#else
        return 300
#endif
    }()
    
    public var alreadyPlacesMarkers = PublishSubject<[CouplePlaceModel]>()
    public var lastPickedPicker = BehaviorRelay<CouplePlaceModel?>(value: nil)
    public var pickedModel = BehaviorRelay<SearchedModel?>(value: nil)
    public var bottomSheetDisappear = PublishSubject<Void>()
    public var progressControl = PublishRelay<Bool>()


    //MARK: StaticDatas
    public let categoryLists = ["전체","맛집","전시회","공원","기타"]
    
    public func dissmissBottomSheet() {
        self.progressControl.accept(false)
        self.coordinator?.dismissSheet()
    }
    
    public func pushSharedCalendar() {
        self.coordinator?.pushSharedCalendar()
    }

    private func evaluateArrivalIfNeeded(location: CLLocation) {
        guard let uid = UserDefaults.standard.string(forKey: "uid"), uid.isEmpty == false else { return }
        let now = Date()

        for plan in currentDatePlans where plan.isCompleted != true {
            guard let scheduledDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) else { continue }
            if Calendar.current.isDate(now, inSameDayAs: scheduledDate) == false {
                continue
            }
            if plan.arrivalRecords[uid] != nil {
                continue
            }
            let target = CLLocation(latitude: plan.mapY, longitude: plan.mapX)
            let distance = location.distance(from: target)
            if distance <= effectiveRadiusMeters(for: plan) {
                saveArrival(plan: plan, uid: uid, arrivedAt: now)
            }
        }
    }

    private func effectiveRadiusMeters(for plan: DatePlanModel) -> Double {
#if DEBUG
        return max(plan.radiusMeters, defaultPlanRadiusMeters)
#else
        return plan.radiusMeters
#endif
    }

    private func saveArrival(plan: DatePlanModel, uid: String, arrivedAt: Date) {
        var updatedPlan = plan
        let arrivedString = arrivedAt.toString(type: .yearToSecond)
        updatedPlan.arrivalRecords[uid] = arrivedString
        updatedPlan.checkIns[uid] = arrivedString
        if let isOnTime = resolveOnTimeIfPossible(plan: updatedPlan) {
            updatedPlan.isOnTime = isOnTime
        }
        if updatedPlan.arrivalRecords.count >= 2 {
            updatedPlan.isCompleted = true
        }
        if let index = currentDatePlans.firstIndex(where: { $0.uuid == plan.uuid }) {
            currentDatePlans[index] = updatedPlan
        }
        arrivalPlanSave.onNext(updatedPlan)
    }

    private func resolveOnTimeIfPossible(plan: DatePlanModel) -> Bool? {
        let scheduledDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) ?? Date()

        guard let uid = UserDefaults.standard.string(forKey: "uid"),
              uid.isEmpty == false else { return nil }
        if let otherUid = UserDefaults.standard.string(forKey: "otherUid"),
           let myArrival = plan.arrivalRecords[uid],
           let otherArrival = plan.arrivalRecords[otherUid],
           let myDate = Date.stringToDate(dateString: myArrival, type: .yearToSecond),
           let otherDate = Date.stringToDate(dateString: otherArrival, type: .yearToSecond) {
            return myDate <= scheduledDate && otherDate <= scheduledDate
        }

        if plan.arrivalRecords.count >= 2 {
            let arrivals = plan.arrivalRecords.values.compactMap {
                Date.stringToDate(dateString: $0, type: .yearToSecond)
            }
            guard arrivals.count >= 2 else { return nil }
            return arrivals.allSatisfy { $0 <= scheduledDate }
        }
        return nil
    }
    
    public struct BottomSheetInput {
        let dismissBottomSheet: Observable<Void>
        let categoryTapped: Observable<Int?>
        let pictureTapped: Observable<(Int?, Data?)>
        let loactionTFtexts: Observable<String>
        let memoTFtexts: Observable<String>
        let viewWillDisappear: Observable<Void>
        let largeSaveBtnTapped: Observable<Void>
        let editBtnTapped: Observable<[Data]>
        let deleteBtnTapped: Observable<Void>
        let threeDoutTapped: Observable<Void>
        let informViewTapped: Observable<Void>
        let deletePicker: Observable<Void>
        
    }
    public struct BottomSheetOutput {
        var categoryIsSelected = BehaviorRelay<[Bool]>(value: [false, false, false, false, false])
        var pictureValues = BehaviorRelay<[Data]>(value: [])
        var btnEnabled = BehaviorRelay<Bool>(value: false)
        var dropPickerIsHidden = BehaviorRelay<Bool>(value: true)
        var alert = PublishRelay<(String, String)>()
        var changeEditStyle = PublishRelay<CouplePlaceModel>()
        var progressControl = PublishRelay<Bool>()

    }
    public func transform(input: BottomSheetInput, disposeBag: DisposeBag) -> BottomSheetOutput {
        let couplePlaceModel = BehaviorRelay<CouplePlaceModel?>(value: nil)
        let output = BottomSheetOutput()
        
        self.progressControl.bind(to: output.progressControl).disposed(by: disposeBag)

        input.threeDoutTapped.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.dropPickerIsHidden.accept(false)
        }).disposed(by: disposeBag)
        input.informViewTapped.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.dropPickerIsHidden.accept(true)
        }).disposed(by: disposeBag)
        
        //TODO: 버튼 관련
        input.editBtnTapped.subscribe(onNext: { [weak self] datas in
            guard let self, let model = lastPickedPicker.value else {return}
            output.pictureValues.accept(datas)
            output.changeEditStyle.accept(model)
        }).disposed(by: disposeBag)
        
        input.deleteBtnTapped.bind(onNext: { [weak self] in
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
            guard let self else {return false}
            
            if let lastPickedPicker = lastPickedPicker.value {
                let model = CouplePlaceModel(category: self.categoryLists[values.2.firstIndex(of: true) ?? 0], name: values.1, description: values.0, mapX: lastPickedPicker.mapX, mapY: lastPickedPicker.mapY, roadAddress: lastPickedPicker.roadAddress, address: lastPickedPicker.address, imagesDatas: values.3)
                couplePlaceModel.accept(model)
            } else if let pickedModel = pickedModel.value {
                let model = CouplePlaceModel(category: self.categoryLists[values.2.firstIndex(of: true) ?? 0], name: values.1, description: values.0, mapX: pickedModel.mapx, mapY: pickedModel.mapy, roadAddress: pickedModel.roadAddress, address: pickedModel.address, imagesDatas: values.3)
                couplePlaceModel.accept(model)
            } else {return false}
            
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
        
        input.viewWillDisappear.map {  [weak self] in
            guard let self else {return}
            pickedModel.accept(nil)
            return () }.bind(to: bottomSheetDisappear).disposed(by: disposeBag)
        
        input.largeSaveBtnTapped.flatMap { [weak self] _ -> Observable<Void> in
                guard let self, let model = couplePlaceModel.value else {
                    return Observable.error(NSError(domain: "", code: -1))
                }
            self.progressControl.accept(true)
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
                self.progressControl.accept(false)

                //TODO: 에러처리
            }).disposed(by: disposeBag)
      
        return output
    }
    
    public struct Input {
        let viewWillAppear: Observable<Void>
        let dDayBtnTapEvent: Observable<Void>
        let alarmBtnTapEvent: Observable<Void>
        let searchBtnTapEvent: Observable<Void>
        let modeChanged: Observable<MapMode>
        let savePlan: Observable<DatePlanDraft>
        let checkInPlan: Observable<DatePlanModel>
        let updatePlan: Observable<DatePlanModel>
        let deletePlan: Observable<String>
        let endTriggerAlertTapEvent: Observable<Void>
        let dissmissBottomSheet: Observable<Void>
        let markerTapped: Observable<CouplePlaceModel>
    }
    
    public struct Output {
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
        var datePlans = PublishSubject<[DatePlanModel]>()
        var presentDatePlanSheet = PublishSubject<SearchedModel>()
        var checkInResult = PublishSubject<CheckInResult>()
    }
    
    
    public init(
        coordinator: MainCoordinator,
        mainUseCase: MainUseCase,
        adMobRepo: AdmobRepository,
        uploadPlaceUseCase: PlaceUseCase,
        datePlanUseCase: DatePlanUseCase,
        pushNotificationService: PushNotificationServiceP
    ) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        self.adMobRepo = adMobRepo
        self.placeUseCase = uploadPlaceUseCase
        self.datePlanUseCase = datePlanUseCase
        self.pushNotificationService = pushNotificationService
    }
    
    public func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(alreadyPlacesMarkers: alreadyPlacesMarkers)
        let currentMode = BehaviorRelay<MapMode>(value: .record)
        
        
        input.markerTapped.subscribe(onNext: { [weak self] model in
            guard let self else {return}
            output.cameraUpdate.onNext(CLLocation( latitude: model.mapY, longitude: model.mapX))
            lastPickedPicker.accept(model)
            self.coordinator?.setupSheet(pickedModel: nil, placeModel: model, type: "inform")
        }).disposed(by: disposeBag)
        
        self.bottomSheetDisappear.subscribe(onNext: { [weak self] in
            guard let self else {return}
            output.deletePickedMarkers.onNext(())
        }).disposed(by: disposeBag)

        self.datePlanUseCase.observePlans()
            .subscribe(onNext: { [weak self] plans in
                guard let self else { return }
                self.currentDatePlans = plans
                output.datePlans.onNext(plans)
                if let location = self.lastKnownLocation {
                    self.evaluateArrivalIfNeeded(location: location)
                }
            })
            .disposed(by: disposeBag)

        if #available(iOS 16.0, *) {
            input.viewWillAppear
                .subscribe(onNext: { [weak self] _ in
                    guard let self else {return}
                    // 장소 검색 시 잠깐 동안 뜨는 용도의 피커 지움
                    if let pickedModel = pickedModel.value {
                        output.searchedMarker.onNext(pickedModel)
                        if currentMode.value == .record {
                            coordinator?.setupSheet(pickedModel: pickedModel, placeModel: nil, type: "small")
                        } else {
                            output.presentDatePlanSheet.onNext(pickedModel)
                        }
                        self.pickedModel.accept(nil)
                    }
                    placeUseCase.fetchAll().subscribe({ [weak self] single in
                        guard let self else {return}
                        switch single {
                        case .success(let places):
                            output.alreadyPlacesMarkers.onNext(places)
                        case .failure(_): break
                            //TODO: Error Alert
                        }
                    }).disposed(by: disposeBag)
                    
                    output.getBottomBannerAd.onNext(adMobRepo.loadBottomBanner())
                    
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
                                if let type = userInfo["type"] {
                                    self.pushNotificationService.addAlarm(
                                        text: text,
                                        date: date,
                                        type: type as? String ?? ""
                                    )
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

        input.modeChanged
            .bind(to: currentMode)
            .disposed(by: disposeBag)

        input.savePlan
            .subscribe(onNext: { [weak self] draft in
                guard let self else { return }
                guard let uid = UserDefaults.standard.string(forKey: "uid"), uid.isEmpty == false else { return }
                let model = DatePlanModel(uuid: UUID().uuidString,
                                          name: draft.name,
                                          memo: draft.memo,
                                          mapX: draft.mapX,
                                          mapY: draft.mapY,
                                          roadAddress: draft.roadAddress,
                                          address: draft.address,
                                          scheduledAt: draft.scheduledAt.toString(type: .yearToSecond),
                                          createdAt: Date().toString(type: .yearToSecond),
                                          createdBy: uid,
                                          notifyEnabled: draft.notifyEnabled,
                                          radiusMeters: defaultPlanRadiusMeters,
                                          dwellSeconds: 180,
                                          checkIns: [:],
                                          arrivalRecords: [:],
                                          isOnTime: nil)
                self.datePlanUseCase.savePlan(model: model)
                    .andThen(self.datePlanUseCase.fetchAll())
                    .subscribe(onSuccess: { plans in
                        output.datePlans.onNext(plans)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)

        input.updatePlan
            .flatMap { [weak self] plan -> Observable<Void> in
                guard let self else { return .empty() }
                return self.datePlanUseCase.savePlan(model: plan)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)

        arrivalPlanSave
            .flatMap { [weak self] plan -> Observable<Void> in
                guard let self else { return .empty() }
                return self.datePlanUseCase.savePlan(model: plan)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)

        input.deletePlan
            .flatMap { [weak self] planId -> Observable<Void> in
                guard let self else { return .empty() }
                return self.datePlanUseCase.deletePlan(uuid: planId)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)

        input.checkInPlan
            .flatMap { [weak self] plan -> Observable<(DatePlanModel, Bool)> in
                guard let self else { return .empty() }
                guard let uid = UserDefaults.standard.string(forKey: "uid"), uid.isEmpty == false else { return .empty() }
                let now = Date()
                let nowString = now.toString(type: .yearToSecond)
                let otherUid = UserDefaults.standard.string(forKey: "otherUid")

                return self.datePlanUseCase.fetchAll()
                    .asObservable()
                    .compactMap { plans in
                        plans.first(where: { $0.uuid == plan.uuid })
                    }
                    .map { latestPlan in
                        var updatedPlan = latestPlan
                        var mergedCheckIns = latestPlan.checkIns
                        mergedCheckIns[uid] = nowString
                        updatedPlan.checkIns = mergedCheckIns

                        let hasOtherCheckIn = mergedCheckIns.count >= 2
                        updatedPlan.isCompleted = hasOtherCheckIn ? true : nil

                        var shouldShowRoulette = false
                        if let resolved = self.resolveOnTimeIfPossible(plan: updatedPlan) {
                            updatedPlan.isOnTime = resolved
                        }
                        let scheduledDate = Date.stringToDate(dateString: latestPlan.scheduledAt, type: .yearToSecond) ?? now
                        let myArrivalDate = updatedPlan.arrivalRecords[uid]
                            .flatMap { Date.stringToDate(dateString: $0, type: .yearToSecond) }
                        let otherArrivalDate: Date? = {
                            if let otherUid,
                               let arrival = updatedPlan.arrivalRecords[otherUid] {
                                return Date.stringToDate(dateString: arrival, type: .yearToSecond)
                            }
                            if let entry = updatedPlan.arrivalRecords.first(where: { $0.key != uid }) {
                                return Date.stringToDate(dateString: entry.value, type: .yearToSecond)
                            }
                            return nil
                        }()
                        let myLate = myArrivalDate.map { $0 > scheduledDate }
                        let otherLate = otherArrivalDate.map { $0 > scheduledDate }
                        if let myLate, let otherLate {
                            shouldShowRoulette = myLate && otherLate == false
                        }
                        return (updatedPlan, shouldShowRoulette)
                    }
            }
            .flatMap { [weak self] updatedPlan, shouldShowRoulette -> Observable<(String, Bool, [DatePlanModel])> in
                guard let self else { return .empty() }
                return self.datePlanUseCase.savePlan(model: updatedPlan)
                    .andThen(self.datePlanUseCase.fetchAll())
                    .map { plans in (updatedPlan.uuid, shouldShowRoulette, plans) }
                    .asObservable()
            }
            .subscribe(onNext: { planId, shouldShowRoulette, plans in
                output.datePlans.onNext(plans)
                output.checkInResult.onNext(CheckInResult(planId: planId, shouldShowRoulette: shouldShowRoulette))
            })
            .disposed(by: disposeBag)
        
        self.mainUseCase.authorizationStatus
            .map({ $0 == .halfallowed || $0 == .disallowed || $0 == .notDetermined})
            .bind(to: output.authorizationAlertShouldShow)
            .disposed(by: disposeBag)
        
        self.mainUseCase.updatedLocation
            .subscribe(onNext: { [weak self] location in
                guard let self else {return}
                
                if let location = location {
                    self.lastKnownLocation = location
                    output.currentLocation.onNext(location)
                    self.evaluateArrivalIfNeeded(location: location)
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
                        .subscribe(onSuccess: { data in
                            let image = data.flatMap { UIImage(data: $0) }
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
                            .subscribe(onSuccess: { data in
                                let image = data.flatMap { UIImage(data: $0) }
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
    public func getDataFromURL(url: URL, completion: @escaping (Data?) -> Void) {
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
