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
    var accessLevelCheck: PublishSubject<AccessLevel>
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
        self.accessLevelCheck = PublishSubject()
    }
    
    func presetUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            var coupleDocumentID = ""
            let userDTO = user.toProfileInsertDTO()
            let dDayDTO = dDay.toDTO()
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
    
    func getUserInfo(_ uid: String) -> Observable<UserModel> {
        return self.firebaseService.getDocument(collection: .Users, document: uid)
            .compactMap{ $0.toObject(UserDTO.self)?.toModel() }
            .asObservable()
    }
    
    func userAccessLevelObserver() {
        
        self.firebaseService.getCurrentUser()
            .subscribe(onSuccess: { user in
                self.firebaseService.observer(collection: .Users, document: user.uid)
                    .map{ data -> AccessLevel in
                        if let accessLev = data["accessLevel"] as? String {
                            switch accessLev {
                            case "authenticated":
                                return .authenticated
                            case "coupleCombined":
                                return .coupleCombined
                            default:
                                return .none
                            }
                        }
                        return .none
                    }
                    .asObservable()
                    .bind(to: self.accessLevelCheck)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func updateProfileImage(image: UIImage) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(()) }
        return self.firebaseService.uploadImage(filePath: uid, image: image)
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
        return Single.create{ single in
            guard let userName = UserDefaults.standard.string(forKey: "userName") else{ return Disposables.create()}
            let coupleRepository = CoupleRepository(firebaseService: self.firebaseService)
            coupleRepository.getCoupleID()
                .subscribe(onSuccess: { coupleID in
                    self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                        .subscribe(onSuccess: { source in
                            let dto = source.toObject(CoupleDTO.self)
                            guard let dto = dto else{ single(.failure(FireStoreError.decodeError)); return }
                            let index = dto.anniName.firstIndex(of: "\(userName) 생일") ?? -1
                            var anniDate = dto.anniDate
                            anniDate[index] = birth
                            let values = ["anniDate": anniDate]
                            self.firebaseService.updateDocument(collection: .Couples, document: coupleID, values: values)
                                .subscribe(onSuccess: {
                                    single(.success(()))
                                }, onFailure: { error in
                                    single(.failure(error))
                                })
                                .disposed(by: self.disposeBag)
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                }, onFailure: { error in
                    single(.failure(error))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
    }
    
    func signOut() -> Single<Void> {
        return Single.create { single in
            do {
                try Auth.auth().signOut()
                single(.success(()))
            } catch let error {
                single(.failure(error))
                return Disposables.create()
            }
            return Disposables.create()
        }
    }
    
    func dropOut() -> Single<Void> {
        guard let user = Auth.auth().currentUser else {
            return .error(FireStoreError.unknown)
        }
        
        return Single.create { single in
            user.delete { error in
                if let error = error {
                    print("dropoutError", error.localizedDescription)
                    single(.failure(error))
                    return
                }
                single(.success(()))
                
            }
            return Disposables.create()
        }
    }
    
    func withdrawal(uid: String, coupleID: String) -> Single<Void> {
        return Single.create{ single in
            self.getUserInfo(uid)
                .subscribe(onNext: { userInfo in
                    self.firebaseService.deleteImageFromStorage(imageURL: userInfo.profileImage ?? "")
                        .subscribe(onSuccess: {
                            self.firebaseService.deleteDocuments(
                                collections: [(.Users, uid),
                                              (.Locations, uid),
                                              (.Couples, coupleID),
                                              (.Chat, coupleID)]
                            )
                            .subscribe(onSuccess: {
                                if let appDomain = Bundle.main.bundleIdentifier {
                                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                }
                                single(.success(()))
                            }, onFailure: { error in
                                single(.failure(error))
                            })
                            .disposed(by: self.disposeBag)
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    //fcm토큰 업데이트
    func updateFcmToken(fcmToken: String) {
        // 🟢 FCM Token 업데이트
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        guard let otherUid = UserDefaults.standard.string(forKey: "otherUid") else{ return }
        
        self.firebaseService.updateDocument(collection: .Users,
                                            document: uid,
                                            values: ["fcmToken" : fcmToken])
        .subscribe(onSuccess: { _ in })
        .disposed(by: disposeBag)
        
        self.firebaseService.updateDocument(collection: .Users,
                                            document: otherUid,
                                            values: ["otherFcmToken" : fcmToken])
        .subscribe(onSuccess: { _ in })
        .disposed(by: disposeBag)
        
    }
}
