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
    var locationManager: CLLocationManager?
    var disposeBag: DisposeBag = DisposeBag()
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    private var locationSubject = PublishSubject<CLLocation>()
    private let firebaseService = DefaultFirebaseService()
    private let uid = UserDefaults.standard.string(forKey: "uid")
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.distanceFilter = CLLocationDistance(3)
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start() {
        self.locationManager?.startUpdatingLocation()
        //startMonitoringSignificantLocationChanges() // 종료 시, 백그라운드 시에도 위치 업데이트받기
    }
    
    func stop() {
        self.locationManager?.stopUpdatingLocation()
    }

    func requestAuthorization() {
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.requestAlwaysAuthorization()
    }
    
    func observeUpdatedAuthorization() -> Observable<CLAuthorizationStatus> {
        return self.authorizationStatus.asObservable()
    }
    
    func observeUpdatedLocation() -> Observable<CLLocation> {
        return locationSubject.asObservable()
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.onNext(location)
        if let uid = self.uid {
            let geopoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            self.firebaseService.createDocument(collection: .Locations,
                                                document: uid,
                                                values: ["location": geopoint])
            .subscribe(onSuccess: {}).disposed(by: disposeBag)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.accept(status)
    }
}
