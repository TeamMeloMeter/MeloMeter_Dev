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
    var updatedLocation: PublishRelay<CLLocation>
    var updatedOtherLocation: PublishRelay<CLLocation?>
    var disposeBag: DisposeBag
    
    required init(locationService: LocationService) {
        self.locationService = locationService
        self.firebaseService = DefaultFirebaseService()
        self.updatedLocation = PublishRelay()
        self.updatedOtherLocation = PublishRelay()
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
