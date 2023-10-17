//
//  DefaultLocationService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/31.
//

import CoreLocation
import Foundation
import FirebaseFirestore
import RxRelay
import RxSwift
import RxCocoa

final class DefaultLocationService: NSObject, LocationService {
    var locationManager = CLLocationManager()
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag = DisposeBag()
    
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var currentLocation = PublishSubject<CLLocation>()
    
    private let uid = UserDefaults.standard.string(forKey: "uid")
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = CLLocationDistance(5)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func start() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }
        //startMonitoringSignificantLocationChanges() // 종료 시, 백그라운드 시에도 위치 업데이트받기
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }

    func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func observeUpdatedAuthorization() -> Observable<CLAuthorizationStatus> {
        return self.authorizationStatus.asObservable()
    }
    
    func observeUpdatedLocation() -> Observable<CLLocation> {
        return currentLocation.asObservable()
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation.onNext(location)
        if let uid = self.uid {
            let geopoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            self.firebaseService.updateDocument(collection: .Locations,
                                                document: uid,
                                                values: ["location": geopoint])
            .subscribe(onSuccess: {}).disposed(by: disposeBag)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
    }
    
}
