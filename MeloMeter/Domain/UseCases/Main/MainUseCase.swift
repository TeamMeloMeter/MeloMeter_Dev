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
    private let locationService: LocationService
    private let firebaseService: DefaultFirebaseService
    private let userRepository: UserRepositoryP
    private let coupleRepository: CoupleRepositoryP
    
    var updatedLocation: PublishRelay<CLLocation>
    var updatedOtherLocation: PublishRelay<CLLocation?>
    var userData: PublishRelay<UserModel>
    var otherUserData: PublishRelay<UserModel>
    var disposeBag: DisposeBag
    
    required init(locationService: LocationService) {
        self.locationService = locationService
        self.firebaseService = DefaultFirebaseService()
        self.userRepository = UserRepository(firebaseService: self.firebaseService)
        self.coupleRepository = CoupleRepository(firebaseService: self.firebaseService)

        self.updatedLocation = PublishRelay()
        self.updatedOtherLocation = PublishRelay()
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
                switch status {
                case .authorizedAlways:
                    self?.authorizationStatus.onNext(.allowed)
                    self?.locationService.start()
                case .authorizedWhenInUse:
                    self?.authorizationStatus.onNext(.halfallowed)
                    self?.locationService.start()
                case .notDetermined:
                    self?.authorizationStatus.onNext(.notDetermined)
                case .denied, .restricted:
                    self?.authorizationStatus.onNext(.disallowed)
                @unknown default:
                    self?.authorizationStatus.onNext(nil)
                }
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestLocation() {
        self.locationService.observeUpdatedLocation()
            .bind(to: self.updatedLocation)
            .disposed(by: disposeBag)
    }
    
    func requestOtherLocation() {
        if let documentID = UserDefaults.standard.string(forKey: "uid2") {
            self.firebaseService.observer(collection: .Locations, document: documentID)
                .map{ firebaseData -> CLLocation? in
                    guard let geopoint = firebaseData["location"] as? GeoPoint else { return nil }
                    return CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
                }
                .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
                .asObservable()
                .bind(to: self.updatedOtherLocation)
                .disposed(by: disposeBag)
        }
    }
    
}

// MARK: getUserInfo
extension MainUseCase {
    func getSinceFirstDay(coupleID: String) -> Single<String> {
        let calendar = Calendar.current
        return self.firebaseService.getDocument(collection: .Couples, document: coupleID)
            .flatMap{ source in
                guard let coupleModel = source.toObject(CoupleDTO.self)?.toModel() else{ return Single.just("D-00")}
                let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
                let sinceDay = calendar.dateComponents([.day], from: currentDate, to: coupleModel.firstDay).day ?? 0
                return Single.just(String(abs(sinceDay)))
            }
    }
    
    func getUserData() {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        self.userRepository.getUserInfo(uid)
            .map{ $0.toModel() }
            .bind(to: self.userData)
            .disposed(by: disposeBag)
    }
    
    func getOtherUserData(uid: String) {
        self.userRepository.getUserInfo(uid)
            .map{ $0.toModel() }
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
                if let url = otherUser.profileImagePath {
                    return self.userRepository.downloadImage(url: url)
                }else {
                    return Single.just(nil)
                }
            }
    }
}
