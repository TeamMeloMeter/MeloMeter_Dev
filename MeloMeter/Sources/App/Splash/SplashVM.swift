//
//  SplashVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/16.
//

import Foundation
import FirebaseAuth
import RxCocoa
import RxRelay
import RxSwift
import GoogleMobileAds

final class SplashVM : NSObject, FullScreenContentDelegate {
    
    private let disposeBag = DisposeBag()
    weak var coordinator: AppCoordinator?
    private var firebaseService: FirebaseService
    private var userRepository: UserRepositoryP
    private var adMobRepo: AdmobRepository
    init(
        coordinator: AppCoordinator,
        firebaseService: FirebaseService,
        userRepository: UserRepositoryP,
        adMobRepo: AdmobRepository
    ) {
        self.coordinator = coordinator
        self.firebaseService = firebaseService
        self.userRepository = userRepository
        self.adMobRepo = adMobRepo
    }
    
    var alert = PublishSubject<String>()
    var loadAdmob = BehaviorSubject<InterstitialAd?>(value: nil)

  
    func setNotification() {
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(selectFlow),
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil
                )
    }
    
    @objc
    func selectFlow() {
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // 앱이 삭제되었거나 처음 설치된 상태
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            if let user = Auth.auth().currentUser {
                try? Auth.auth().signOut()
            }
        }

        VersionService.shared.getAppStoreVersion(completion: { [weak self] appStoreVer in
            guard let self else {return}
            if let appStoreVer, Float(VersionService.shared.getDeviceVersion()) ?? -0.0 < Float(appStoreVer) ?? 0.0 {
                
                alert.onNext("appStore")
            } else if appStoreVer == "offLine" {
                alert.onNext("offLine")
            } else {
                PushNotificationService.shared.setupAppStateNotifications()

                adMobRepo.loadInterstitial().subscribe({ single in
                        switch single {
                        case .success(let interstitialAd):
                            interstitialAd.fullScreenContentDelegate = self
                            self.loadAdmob.onNext(interstitialAd)
                            
                        case .failure(_):
                            self.flowPick()
                        }
                    
                    
                }).disposed(by: disposeBag)
               
            }
            
            
        })
        
     
    }
    func getAccessLevel() -> Single<AccessLevel> {
        return Single.create { single in
            self.firebaseService.getCurrentUser()
                .subscribe(onSuccess: { [weak self] user in
                    guard let self = self else{ return }

                    self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .subscribe(onSuccess: {[weak self] data in
                            guard let self = self else{ return }
                            //MARK: getDocument 로 return 받는 model 의 경우에서 phoneNumber 가 가끔 empty 일 경우를 개선해서 empty 인 경우 update 후 진행.
                            if data["phoneNumber"] == nil, let phoneNumber = user.phoneNumber {
                                self.firebaseService.updateDocument(collection: .Users, document: user.uid, values: ["phoneNumber": phoneNumber]).subscribe()
                                    .disposed(by: disposeBag)
                            }
                            
                           
                            
                            single(.success(UserDefaultsRepo.shared.persistent(document: data)))
                            
//                            guard let accessLevel = data["accessLevel"] as? String else{ single(.success(.none)); return}
//                            switch accessLevel {
//                            case "authenticated":
//                                single(.success(.authenticated))
//                            case "coupleCombined":
//                                if UserDefaultsRepo.shared.persistCoupleCombined(fcmToken: data["fcmToken"], coupleID: data["coupleID"], phoneNumber: user.phoneNumber, uid: data["uid"]) {
//                                    single(.success(.coupleCombined))
//
//                                } else {
//                                    single(.success(.authenticated))
//                                }
//                            case "complete":
//                                if UserDefaultsRepo.shared.persistCompleted(fcmToken: data["fcmToken"], otherUid: data["otherUid"], coupleID: data["coupleID"], phoneNumber: user.phoneNumber, uid: data["uid"]) {
//                                    single(.success(.complete))
//
//                                } else if UserDefaultsRepo.shared.persistCoupleCombined(fcmToken: data["fcmToken"], coupleID: data["coupleID"], phoneNumber: data["phoneNumber"], uid: data["uid"]) {
//                                    single(.success(.coupleCombined))
//
//                                } else {
//                                    single(.success(.authenticated))
//                                }
//                            case "start":
//                                let deleteData = self.userRepository.withdrawal(uid: user.uid)
//                                let dropOut = self.userRepository.dropOut()
//                                Single.zip(deleteData, dropOut)
//                                    .subscribe(onSuccess: { _, _ in
//                                        single(.success(.start))
//                                    }, onFailure: { error in
//                                        single(.failure(error))
//                                    })
//                                    .disposed(by: self.disposeBag)
//                            default:
//                                single(.success(.none))
//                            }
                        }, onFailure: { _ in
                            single(.success(.none))
                        })
                        .disposed(by: self.disposeBag)
                }, onFailure: { _ in
                    single(.success(.none))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}

extension SplashVM {
    
    func flowPick() {
        self.getAccessLevel()
            .subscribe(onSuccess: {[weak self] state in
            
                guard let self = self else{ return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    switch state {
                    case .none, .start:
                        self.coordinator?.connectLogInFlow(accessLevel: false)
                    case .authenticated:
                        self.coordinator?.connectLogInFlow(accessLevel: true)
                    case .coupleCombined:
                        self.coordinator?.connectPresetFlow()
                    case .complete:
                        self.coordinator?.connectTabBarFlow()
                    }
                }
            }, onFailure: { _ in
                self.coordinator?.connectLogInFlow(accessLevel: false)
            })
            .disposed(by: disposeBag)
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        flowPick()
    }
}
