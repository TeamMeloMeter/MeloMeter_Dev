//
//  MainUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/31.
//

import UIKit
import RxSwift
import RxRelay
import CoreLocation
import FirebaseFirestore

enum LocationAuthorizationStatus {
    case allowed, halfallowed, disallowed, notDetermined
}

class MainUseCase {
    var authorizationStatus = BehaviorSubject<LocationAuthorizationStatus?>(value: nil)
    private var locationService: DefaultLocationService
    private var firebaseService: FireStoreService
    private var userRepository: UserRepositoryP
    private var coupleRepository: CoupleRepositoryP
    
    var updatedLocation: BehaviorRelay<CLLocation?>
    var updatedOtherLocation: BehaviorRelay<CLLocation?>
    var userData: PublishRelay<UserModel?>
    var otherUserData: PublishRelay<UserModel?>
    var disposeBag: DisposeBag
    
    required init(locationService: DefaultLocationService, firebaseService: FireStoreService) {
        self.locationService = locationService
        self.firebaseService = firebaseService
        self.userRepository = UserRepository(firebaseService: self.firebaseService,
                                             chatRepository: ChatRepository(firebaseService: self.firebaseService))
        self.coupleRepository = CoupleRepository(firebaseService: self.firebaseService)
        
        self.updatedLocation = BehaviorRelay(value: CLLocation(latitude: 0, longitude: 0))
        self.updatedOtherLocation = BehaviorRelay(value: CLLocation(latitude: 0, longitude: 0))
        self.userData = PublishRelay()
        self.otherUserData = PublishRelay()
        self.disposeBag = DisposeBag()
    }
    
    func locationStart() {
        self.locationService.start()
    }
    
    func locationStop() {
        self.locationService.stop()
    }
    
    func requestAuthorization() {
        self.locationService.requestAuthorization()
    }

    func checkAuthorization() {
        self.locationService.observeUpdatedAuthorization()
            .subscribe(onNext: { [weak self] status in
                guard let self = self else{ return }
                switch status {
                case .authorizedAlways:
                    self.authorizationStatus.onNext(.allowed)
                    self.locationService.start()
                case .authorizedWhenInUse:
                    self.authorizationStatus.onNext(.halfallowed)
                    self.locationService.start()
                case .notDetermined:
                    self.authorizationStatus.onNext(.notDetermined)
                case .denied, .restricted:
                    self.authorizationStatus.onNext(.disallowed)
                @unknown default:
                    self.authorizationStatus.onNext(nil)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func requestLocation() {
        self.locationService.observeUpdatedLocation()
            .bind(to: self.updatedLocation)
            .disposed(by: disposeBag)
    }
    
    func requestOtherLocation() {
        self.userData
            .subscribe(onNext: { userInfo in
                self.firebaseService.observer(collection: .Locations, document: userInfo?.otherUid ?? "")
                    .map{ firebaseData -> CLLocation? in
                        guard let geopoint = firebaseData["location"] as? GeoPoint else { return nil }
                        return CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
                    }
                    .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
                    .asObservable()
                    .bind(to: self.updatedOtherLocation)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: getUserInfo
extension MainUseCase {
    func getSinceFirstDay(coupleID: String) -> Single<String> {
        let calendar = Calendar.current
        return self.firebaseService.getDocument(collection: .Couples, document: coupleID)
            .flatMap{ source in
                guard let coupleModel = source.toObject(CoupleDTO.self)?.toModel() else{ return Single.just("")}
                
                //주기적 알림 등록
                PushNotificationService.shared.addRepeatAlarm(coupleModel.anniversaries, coupleModel.firstDay)
                //fcm토큰 업데이트
                guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else{ return Single.just("") }
                self.userRepository.updateFcmToken(fcmToken: fcmToken)

                let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
                let sinceDay = calendar.dateComponents([.day], from: currentDate, to: coupleModel.firstDay).day ?? 0
                return Single.just(String(abs(sinceDay)))
            }
            .catchAndReturn("")
    }
    
    func getUserData() {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil))
            .bind(to: self.userData)
            .disposed(by: disposeBag)
    }
    
    func getOtherUserData(uid: String) {
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil))
            .bind(to: self.otherUserData)
            .disposed(by: disposeBag)
    }
    
    func getMyProfileImage(url: String) -> Single<UIImage?> {
        return self.userRepository.downloadImage(url: url)
    }
    
    func getOtherProfileImage(otherUid: String) -> Single<UIImage?> {
        return self.userRepository.getUserInfo(otherUid)
            .asSingle()
            .flatMap{ otherUser in
                if let url = otherUser.profileImage {
                    return self.userRepository.downloadImage(url: url)
                }else {
                    return Single.just(nil)
                }
            }
            .catchAndReturn(nil)
    }
    
    func disconnectionObserver() -> Single<Bool> {
        return Single.create{ single in
            self.userRepository.userAccessLevelObserver()
            self.userRepository.accessLevelCheck
                .subscribe(onNext: { accessLevel in
                    if accessLevel == .authenticated {
                        single(.success(true))
                        return
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
    }
    
    func excuteRemoveData() -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid")
        else{ return Single.just(()) }
        return self.userRepository.removeOtherData(uid: uid)
    }
}
