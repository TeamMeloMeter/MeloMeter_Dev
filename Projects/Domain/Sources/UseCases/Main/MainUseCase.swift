//
//  MainUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/31.
//

import Foundation
import RxSwift
import RxRelay
import CoreLocation
import GoogleMobileAds

public enum LocationAuthorizationStatus {
    case allowed, halfallowed, disallowed, notDetermined
}

public class MainUseCase {
    public var authorizationStatus = BehaviorSubject<LocationAuthorizationStatus?>(value: nil)
    private var firebaseService: FirebaseService
    private var userRepository: UserRepositoryP
    private var coupleRepository: CoupleRepositoryP
    private var adMobRepo: AdmobRepositoryP
    private var sharedDataRepo: SharedDataRepoP
    private var notificationService: PushNotificationServiceP
    
    public var updatedLocation: BehaviorRelay<CLLocation?>
    public var updatedOtherLocation: BehaviorRelay<CLLocation?>
    public var userData: PublishRelay<UserModel?>
    public var otherUserData: PublishRelay<UserModel?>
    public var disposeBag: DisposeBag
    
    public required init(
        firebaseService: FirebaseService,
        userRepository: UserRepositoryP,
        coupleRepository: CoupleRepositoryP,
        adMobRepo: AdmobRepositoryP,
        sharedDataRepo: SharedDataRepoP,
        notificationService: PushNotificationServiceP
    ) {
        self.firebaseService = firebaseService
        self.userRepository = userRepository
        self.coupleRepository = coupleRepository
        self.adMobRepo = adMobRepo
        
        self.updatedLocation = BehaviorRelay(value: CLLocation(latitude: 0, longitude: 0))
        self.updatedOtherLocation = BehaviorRelay(value: CLLocation(latitude: 0, longitude: 0))
        self.userData = PublishRelay()
        self.otherUserData = PublishRelay()
        self.disposeBag = DisposeBag()
        self.sharedDataRepo = sharedDataRepo
        self.notificationService = notificationService
    }
    
    

    public func requestAuthorization() {
        LocationService.shared.requestAuthorization()
    }

    public func checkAuthorization() {
        LocationService.shared.observeUpdatedAuthorization()
            .subscribe(onNext: { [weak self] status in
                guard let self else {return }

                switch status {
                case .authorizedAlways:
                    self.authorizationStatus.onNext(.allowed)
                    LocationService.shared.start()
                case .authorizedWhenInUse:
                    self.authorizationStatus.onNext(.halfallowed)
                    LocationService.shared.start()
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
    
    public func requestLocation() {
        LocationService.shared.observeUpdatedLocation()
            .bind(to: self.updatedLocation)
            .disposed(by: disposeBag)
    }
    
    public func requestOtherLocation() {
        self.userData
            .subscribe(onNext: { [weak self] userInfo in
                guard let self else {return}
                guard let userInfo, let otherUid = userInfo.otherUid else {
                    self.updatedLocation.accept(nil)
                    return }
                self.firebaseService.observeLocation(document: otherUid)
                    .catchAndReturn(nil)
                    .bind(to: self.updatedOtherLocation)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: getUserInfo
extension MainUseCase {
    public func getSinceFirstDay(coupleID: String) -> Single<String> {
        let calendar = Calendar.current
        return self.coupleRepository.getCoupleDocument()
            .map { coupleModel in
                self.sharedDataRepo.saveStartDate(startDate: coupleModel.firstDay.toString(type: .yearToDay))

                // 주기적 알림 등록
                self.notificationService.addRepeatAlarm(coupleModel.anniversaries, coupleModel.firstDay)
                // fcm토큰 업데이트
                if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                    self.userRepository.updateFcmToken(fcmToken: fcmToken)
                }

                let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
                let sinceDay = (calendar.dateComponents([.day], from: currentDate, to: coupleModel.firstDay).day ?? 0) - 1
                return String(abs(sinceDay))
            }
            .catchAndReturn("")
    }
    
    public func getUserData() {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else { return }
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil)).map { user in self.sharedDataRepo.saveMyName(myName: user.name ?? ""); return user}
            .bind(to: self.userData)
            .disposed(by: disposeBag)
    }
    
    public func getOtherUserData(uid: String) {
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil)).map { [weak self] result in
                guard let self else {return result}
                let otherName = result.name ?? ""
                self.sharedDataRepo.saveOthersName(othersName: otherName)
                return result
            }
            .bind(to: self.otherUserData)
            .disposed(by: disposeBag)
        
        
    }
    
    public func getMyProfileImage(url: String) -> Single<Data?> {
        return self.userRepository.downloadImage(url: url)
    }
    
    public func getOtherProfileImage(otherUid: String) -> Single<Data?> {
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
    
    public func disconnectionObserver() -> Single<Bool> {
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
    
    public func excuteRemoveData() -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid")
        else{ return Single.just(()) }
        return self.userRepository.removeOtherData(uid: uid)
    }
}
//MARK: AdMob
extension MainUseCase {
    
    public func getBottomBannerAd() -> BannerView {
        return adMobRepo.loadBottomBanner()
    }
    
}
