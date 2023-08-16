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

final class DefaultLocationService: NSObject, LocationService {
    let locationManager = CLLocationManager()
    var disposeBag: DisposeBag = DisposeBag()
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    private var currentLocation = PublishRelay<CLLocation>()
    private let firebaseService = DefaultFirebaseService()
    private let uid = UserDefaults.standard.string(forKey: "uid")
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = CLLocationDistance(1)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func start() {
        self.locationManager.startUpdatingLocation()
        //startMonitoringSignificantLocationChanges() // 종료 시, 백그라운드 시에도 위치 업데이트받기
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }

    func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
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
        print("위치업데이트??", manager,locations)

        guard let location = locations.last else { return }
        print("위치업데이트", location.coordinate.latitude, location.coordinate.longitude)
        currentLocation.accept(location)
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
}
