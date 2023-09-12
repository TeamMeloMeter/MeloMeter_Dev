//
//  BackgroundTaskManager.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import Foundation
import FirebaseFirestore
import RxSwift

class BackgroundTaskManager {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    func addAlarm(title: String, body: String, date: String) -> Void {
        
        print("🟢 add알림 함수 실행")
        
        guard let uid = UserDefaults.standard.string(forKey: "uid") else { return }
        
        let values = [
            "title" : title,
            "body" : body,
            "date" : date
        ]
        //푸시노티
        PushNotificationService.shared.sendPushNotification(title: title, body: body)
        
        self.firebaseService.updateDocument(collection: .Alarm, document: uid, values: ["alarmList" : FieldValue.arrayUnion([values]) ]).subscribe(onSuccess: { print("🟢알림저장")})
        
        
    }
    
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
