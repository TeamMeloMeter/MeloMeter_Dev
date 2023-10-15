//
//  LocationService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/31.
//

import CoreLocation
import Foundation

import RxRelay
import RxSwift

protocol LocationService {
    var authorizationStatus: BehaviorRelay<CLAuthorizationStatus> { get set }
    func start()
    func stop()
    func requestAuthorization()
    func observeUpdatedAuthorization() -> Observable<CLAuthorizationStatus>
    func observeUpdatedLocation() -> Observable<CLLocation>
}
