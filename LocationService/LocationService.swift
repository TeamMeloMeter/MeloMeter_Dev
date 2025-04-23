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

final class LocationService: NSObject {
    
    static var shared = LocationService()
    
    private var isBack = false
    private var isFore = true
    
    
    var locationManager = CLLocationManager()
    var firebaseService: FirebaseService
    var disposeBag: DisposeBag = DisposeBag()
    
    var authorizationStatus: BehaviorRelay<CLAuthorizationStatus>
    var currentLocation = PublishSubject<CLLocation>()
    
    private override init() {
        self.firebaseService = DefaultFirebaseService()
        self.locationManager.distanceFilter = CLLocationDistance(1)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        authorizationStatus = BehaviorRelay(value: self.locationManager.authorizationStatus )

        super.init()
        self.locationManager.delegate = self

    }
    
    
    
    func switchToSignificant() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        
        isBack = true
        isFore = false
    }
    
    func start() {
        // 위치 서비스가 활성화되어 있는지 확인하고, 백그라운드에서 처리합니다.
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            // 권한 상태가 승인된 경우에만 위치 업데이트를 시작
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.stopMonitoringSignificantLocationChanges()
                
                self.locationManager.startUpdatingLocation()
                
                isFore = true
                isBack = false
            }
        }
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

extension LocationService: CLLocationManagerDelegate {
    
    
    //MARK: 위치 주기적으로 업데이트.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        if isBack {
            PushNotificationService.shared.localPushNotification(title: "locaiton Updated", body: " \(locations) location updated")
        }
        

        
        self.currentLocation.onNext(lastLocation)
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            let geopoint = GeoPoint(latitude: lastLocation.coordinate.latitude,
                                    longitude: lastLocation.coordinate.longitude)
            
            self.firebaseService.updateDocument(collection: .Locations,
                                                document: uid,
                                                values: ["location": geopoint])
            .subscribe(onSuccess: {
                print("success updateDoc \(geopoint)")
            }).disposed(by: disposeBag)
            
        }
        
    }
    
    //MARK: 위치 권한 변경 시
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
    }
    
}
