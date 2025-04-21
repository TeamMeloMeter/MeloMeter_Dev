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
    
    private var isForegroundService: Bool?
    var locationManager = CLLocationManager()
    var firebaseService: FirebaseService
    var disposeBag: DisposeBag = DisposeBag()
    
    var authorizationStatus: BehaviorRelay<CLAuthorizationStatus>
    var currentLocation = PublishSubject<CLLocation>()
    
    override init() {
        self.firebaseService = DefaultFirebaseService()
        self.locationManager.distanceFilter = CLLocationDistance(1)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        authorizationStatus = BehaviorRelay(value: self.locationManager.authorizationStatus )
        
        print("\(self.locationManager.authorizationStatus) self.locationManager.authorizationStatus")
        super.init()
        self.locationManager.delegate = self

        
        
        
       
        
    }
    
    
    
    func switchToSignificant() {
        print("📦 startMonitoringSignificantLocationChanges 시작")
        isForegroundService = false
        
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func start() {
        // 위치 서비스가 활성화되어 있는지 확인하고, 백그라운드에서 처리합니다.
        print("들 옴 s t a r t")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            
            // 권한 상태가 승인된 경우에만 위치 업데이트를 시작
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.stopMonitoringSignificantLocationChanges()
                self.locationManager.startUpdatingLocation()
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

extension DefaultLocationService: CLLocationManagerDelegate {
    
    
    //MARK: 위치 주기적으로 업데이트.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("주기적")
        if let isForegroundService, !isForegroundService {
            PushNotificationService.shared.localPushNotification(title: "update", body: "updateLocation in Background")
            
        }
        
        self.currentLocation.onNext(location)
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            let geopoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            
            self.firebaseService.updateDocument(collection: .Locations,
                                                document: uid,
                                                values: ["location": geopoint])
            .subscribe(onSuccess: {
                print("success updateDoc \(geopoint)")
            }).disposed(by: disposeBag)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        self.authorizationStatus.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
    }
    
}
