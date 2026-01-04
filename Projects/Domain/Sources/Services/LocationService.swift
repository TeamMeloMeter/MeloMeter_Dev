//
//  DefaultLocationService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/31.
//

import CoreLocation
import Foundation
import RxRelay
import RxSwift

public final class LocationService: NSObject {
    
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var firebaseService: FirebaseService?
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var authorizationStatus: BehaviorRelay<CLAuthorizationStatus>
    private var currentLocation = PublishSubject<CLLocation>()
    private let uploadInterval: TimeInterval = 600
    private var lastUploadAt: Date?
    
    private override init() {
        self.locationManager.distanceFilter = CLLocationDistance(3)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        authorizationStatus = BehaviorRelay(value: self.locationManager.authorizationStatus )

        super.init()
        self.locationManager.delegate = self

    }
    
    
    public func configure(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
    }
    
    public func switchToSignificant() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()

    }
    
    public func start() {
        // 위치 서비스가 활성화되어 있는지 확인하고, 백그라운드에서 처리합니다.
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            // 권한 상태가 승인된 경우에만 위치 업데이트를 시작
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.stopMonitoringSignificantLocationChanges()
                
                self.locationManager.startUpdatingLocation()

            }
        }
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    public func requestAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    public func observeUpdatedAuthorization() -> Observable<CLAuthorizationStatus> {
        return self.authorizationStatus.asObservable()
    }
    
    public func observeUpdatedLocation() -> Observable<CLLocation> {
        return currentLocation.asObservable()
    }
    
    
}

extension LocationService: CLLocationManagerDelegate {
    
    
    //MARK: 위치 주기적으로 업데이트.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        self.currentLocation.onNext(lastLocation)
        guard let firebaseService else { return }
        let now = Date()
        if let lastUploadAt, now.timeIntervalSince(lastUploadAt) < uploadInterval {
            return
        }
        lastUploadAt = now
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            firebaseService.updateLocation(document: uid, location: lastLocation)
            .subscribe(onSuccess: {
                print("success update location")
            }).disposed(by: disposeBag)
            
        }
        
    }
    
    //MARK: 위치 권한 변경 시
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.accept(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.currentLocation.onNext(CLLocation(latitude: 0, longitude: 0))
    }
    
}
