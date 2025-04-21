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
    static var shared = DefaultLocationService()
    var locationManager = CLLocationManager()
    var firebaseService: FirebaseService
    var disposeBag: DisposeBag = DisposeBag()
    
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var currentLocation = PublishSubject<CLLocation>()
    
    private let uid = UserDefaults.standard.string(forKey: "uid")
    override init() {
        self.firebaseService = DefaultFirebaseService()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = CLLocationDistance(50)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
 

    func switchToSignificant() {
        print("📦 startMonitoringSignificantLocationChanges 시작")
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func start() {
//        DispatchQueue.global().async {
//            if CLLocationManager.locationServicesEnabled() {
//                self.locationManager.startUpdatingLocation()
//            }
//        }
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
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
    
    
    //MARK: 위치 주기적으로 업데이트.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation.onNext(location)
        if let uid = self.uid {
            let geopoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
    
            self.firebaseService.updateDocument(collection: .Locations,
                                                document: uid,
                                                values: ["location": geopoint])
            .subscribe(onSuccess: {
                print("success")
            }).disposed(by: disposeBag)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
    }
    
}
