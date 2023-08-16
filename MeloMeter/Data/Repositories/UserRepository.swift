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
    
    func presetUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            var coupleDocumentID = ""
            //모델객체 -> DTO객체
            let userDTO = user.toProfileInsertDTO()
            let dDayDTO = dDay.toDTO() // [이름] [날짜]
            UserDefaults.standard.set(userDTO.name, forKey: "userName")
            guard let userValues = userDTO.asDictionary, var coupleValues = dDayDTO.asDictionary else { return Disposables.create() }
            coupleValues["anniName"] = FieldValue.arrayUnion(coupleValues["anniName"] as! [Any])
            coupleValues["anniDate"] = FieldValue.arrayUnion(coupleValues["anniDate"] as! [Any])
            self.firebaseService.getDocument(collection: .Users, document: userDTO.uid)
                .subscribe(onSuccess: { userInfo in
                    guard let coupleID = userInfo["coupleID"] as? String else{ single(.failure(FireStoreError.unknown)); return }
                    coupleDocumentID = coupleID
                    let couplesUpdate = self.firebaseService.updateDocument(collection: .Couples,
                                                                                   document: coupleDocumentID,
                                                                                   values: coupleValues)
                    let usersUpdate = self.firebaseService.createDocument(collection: .Users,
                                                               document: userDTO.uid,
                                                               values: userValues)
                    Single.zip(couplesUpdate, usersUpdate)
                    .subscribe(onSuccess: { _,_ in
                        self.firebaseService.setAccessLevel(.complete)
                            .subscribe(onSuccess: {
                                single(.success(()) )
                            })
                            .disposed(by: self.disposeBag)
                    }, onFailure: { error in
                        single(.failure(error))
                    })
                    .disposed(by: self.disposeBag)
                })
                .disposed(by: disposeBag)
            
            return Disposables.create()
        }
        
    }
    
    func getUserInfo(_ uid: String) -> Observable<UserDTO> {
        return self.firebaseService.getDocument(collection: .Users, document: uid)
            .compactMap{ $0.toObject(UserDTO.self) }
            .asObservable()
    }
    
    func userAccessLevelObserver() {
        
        self.firebaseService.getCurrentUser()
            .subscribe(onSuccess: { user in
                self.firebaseService.observer(collection: .Users, document: user.uid)
                    .map{ data -> Bool in
                        if let isCombined = data["accessLevel"] as? String {
                            if isCombined == "coupleCombined" {
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

    func signOut() {
        try? Auth.auth().signOut()
    }
}
