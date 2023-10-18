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
    init(
        coordinator: AppCoordinator,
        firebaseService: FirebaseService,
        userRepository: UserRepositoryP
    ) {
        self.coordinator = coordinator
        self.firebaseService = firebaseService
        self.userRepository = userRepository
    }
    
    func selectFlow() {
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
                                single(.success(.coupleCombined))
                            case "complete":
                                single(.success(.complete))
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
