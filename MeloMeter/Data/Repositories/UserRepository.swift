//
//  UserRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/05.
//

import Foundation
import Firebase
import RxSwift
import RxRelay
import FirebaseFirestore

class UserRepository: UserRepositoryP {
    
    private var firebaseService: FireStoreService
    private var disposeBag: DisposeBag
    var combineCheck: PublishRelay<Bool>
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
        self.combineCheck = PublishRelay()
    }
    
    func getUserInfo(_ uid: String) -> Observable<UserDTO> {
        return self.firebaseService.getDocument(collection: .Users, document: uid)
            .map{ $0.toObject(UserDTO.self)! }
            .asObservable()
    }
    
    func userAccessLevelObserver() {
        
        self.firebaseService.getCurrentUser()
            .subscribe(onSuccess: { user in
                self.firebaseService.observer(collection: .Users, document: user.uid)
                    .map{ data -> Bool in
                        if let isCombined = data["accessLevel"] as? String {
                            if isCombined == "CoupleCombined" {
                                return true
                            }
                        }
                        return false
                    }
                    .asObservable()
                    .bind(to: self.combineCheck)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func updateUserInfo(value: [String: String]) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(())}
        return self.firebaseService.updateDocument(collection: .Users,
                                                   document: uid,
                                                   values: value.asDictionary ?? [:])
    }

}
