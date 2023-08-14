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
    
    func updateProfileImage(image: UIImage) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(()) }
        return self.firebaseService.uploadImage(image: image)
            .flatMap{ url in
                return self.firebaseService.updateDocument(collection: .Users, document: uid, values: ["profileImagePath": url] as? [String: Any] ?? [:])
            }
    }
    
    func downloadImage(url: String) -> Single<UIImage?> {
        return self.firebaseService.downloadImage(urlString: url)
    }
    
    func updateUserInfo(value: [String: String]) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(())}
        if value.first?.key == "birth" {
            return self.setAnniversaries(uid: uid, birth: value["birth"] ?? "")
                .flatMap { _ in
                    return self.firebaseService.updateDocument(collection: .Users,
                                                               document: uid,
                                                               values: value.asDictionary ?? [:])
                }
                
        }else {
            return self.firebaseService.updateDocument(collection: .Users,
                                                       document: uid,
                                                       values: value.asDictionary ?? [:])
        }
    }
    
    private func setAnniversaries(uid: String, birth: String) -> Single<Void> {
        guard let userName = UserDefaults.standard.string(forKey: "userName") else{ return Single.just(()) }
        let coupleRepository = CoupleRepository(firebaseService: self.firebaseService)
        return coupleRepository.getCoupleID()
            .flatMap{ coupleID -> Single<Void> in
                self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                    .flatMap{ source -> Single<Void> in
                        let dto = source.toObject(CoupleDTO.self)
                        guard let dto = dto else{ return Single.just(()) }
                        let index = dto.anniName.firstIndex(of: "\(userName) 생일") ?? -1
                        var anniDate = dto.anniDate
                        anniDate[index] = birth
                        let values = ["anniDate": anniDate]
                        return self.firebaseService.updateDocument(collection: .Couples, document: coupleID, values: values)
                    }
            }
    }

}
