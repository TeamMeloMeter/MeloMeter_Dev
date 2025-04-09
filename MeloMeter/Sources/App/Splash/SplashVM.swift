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

final class SplashVM {

    private let disposeBag = DisposeBag()
    weak var coordinator: AppCoordinator?
    private var firebaseService: FirebaseService
    private var userRepository: UserRepositoryP
    private var versionRepository: VersionRepositoryP
    private var userDefaultsRepo: UserDefaultsRepoP
    init(
        coordinator: AppCoordinator,
        firebaseService: FirebaseService,
        userRepository: UserRepositoryP,
        versionRepository: VersionRepositoryP,
        userDefaultsRepo: UserDefaultsRepoP
    ) {
        self.coordinator = coordinator
        self.firebaseService = firebaseService
        self.userRepository = userRepository
        self.versionRepository = versionRepository
        self.userDefaultsRepo = userDefaultsRepo
    }
    
    var alert = PublishSubject<String>()
  
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
        let device = versionRepository.getDeviceVersion()
        versionRepository.getAppStoreVersion(completion: { [weak self] appStoreVer in
            guard let self else {return}
            if let appStoreVer, Float(device) ?? -0.0 < Float(appStoreVer) ?? 0.0  {
                
                alert.onNext("appStore")
            } else if appStoreVer == "offLine" {
                alert.onNext("offLine")
            } else {
                //MARK: 초기에 UserDefaults 다 지우고 시작
                //TODO: 이후 로직 개선 시 이전 빌드 시 APP Crash 등으로 문제가 있을 때 지우도록 개선할 수 있을듯.
                userDefaultsRepo.resetAllUserDefaults()
                self.getAccessLevel()
                    .subscribe(onSuccess: {[weak self] state in
                        guard let self = self else{ return }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
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
            
            
        })
        
     
    }
    func getAccessLevel() -> Single<AccessLevel> {
        return Single.create { single in
            self.firebaseService.getCurrentUser()
                .subscribe(onSuccess: {[weak self] user in
                    guard let self = self else{ return }
                    
                    self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .subscribe(onSuccess: {[weak self] data in

                            
                            guard let self = self else{ return }
                            guard let accessLevel = data["accessLevel"] as? String else{ single(.success(.none)); return}
                            switch accessLevel {
                            case "authenticated":
                                
                                single(.success(.authenticated))
                            case "coupleCombined":
                                
                                if userDefaultsRepo.persistUserSessionData(fcmToken: data["fcmToken"], otherUid: data["otherUid"], coupleID: data["coupleID"], phoneNumber: data["phoneNumber"], uid: data["uid"]) {
                                    single(.success(.coupleCombined))

                                } else {
                                    single(.success(.none))

                                }
                                
                              
                                
                                single(.success(.coupleCombined))
                            case "complete":
                                if userDefaultsRepo.persistUserSessionData(fcmToken: data["fcmToken"], otherUid: data["otherUid"], coupleID: data["coupleID"], phoneNumber: data["phoneNumber"], uid: data["uid"]) {
                                    single(.success(.coupleCombined))

                                } else {
                                    single(.success(.none))

                                }
                            case "start":
                                let deleteData = self.userRepository.withdrawal(uid: user.uid)
                                let dropOut = self.userRepository.dropOut()
                                Single.zip(deleteData, dropOut)
                                    .subscribe(onSuccess: { _, _ in
                                        single(.success(.start))
                                    }, onFailure: { error in
                                        single(.failure(error))
                                    })
                                    .disposed(by: self.disposeBag)
                            default:
                                single(.success(.none))
                            }
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
