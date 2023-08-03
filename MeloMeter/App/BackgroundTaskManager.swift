//
//  BackgroundTaskManager.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import RxSwift
import RxCocoa

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private let disposeBag = DisposeBag()
    
    private init() {}
    
//    func startBackgroundTask() {
//        UIApplication.shared.rx.backgroundTask {
//            let locationService = DefaultLocationService()
//            let firestoreService = DefaultFirebaseService()
////            let viewModel = LocationViewModel(locationService: locationService, firestoreService: firestoreService)
////            viewModel.startLocationUpdates()
//
//        }.subscribe(onNext: { backgroundTask in
//            // When the background task completes, you can stop location updates and clean up resources.
//            let locationService = DefaultLocationService()
////            let viewModel = LocationViewModel(locationService: locationService)
////            viewModel.stopLocationUpdates()
//            backgroundTask.setTaskCompleted()
//        })
//        .disposed(by: disposeBag)
//    }
}
