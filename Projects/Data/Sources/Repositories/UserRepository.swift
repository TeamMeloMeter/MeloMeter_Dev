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
import Domain

public class UserRepository: UserRepositoryP {
    
    private var firebaseService: FirebaseService
    private var disposeBag: DisposeBag
    public var accessLevelCheck: PublishSubject<AccessLevel>
    private var chatRepository: ChatRepositoryP
    
    public init(firebaseService: FirebaseService,
         chatRepository: ChatRepositoryP)
    {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
        self.accessLevelCheck = PublishSubject()
        self.chatRepository = chatRepository
    }
    
    
//    func presetUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void> {
//        return Single.create { [weak self] single in
//            guard let self = self else { return Disposables.create() }
//            var coupleDocumentID = ""
//            
//            firebaseService.getCurrentUser().subscribe({ single in
//                switch single {
//                case .success(let susccessUser):
//                    //
//                    break
//                case .failure(let err):
//                    //
//                    break
//                }
//                
//                
//            }).disposed(by: disposeBag)
//            
//            let userDTO = user.toProfileInsertDTO(uid: <#String#>, phoneNumber: <#String#>)
//            let dDayDTO = dDay.toDTO()
//            UserDefaults.standard.set(userDTO.name, forKey: "userName")
//            guard let userValues = userDTO.asDictionary, var coupleValues = dDayDTO.asDictionary else { return Disposables.create() }
//            coupleValues["anniName"] = FieldValue.arrayUnion(coupleValues["anniName"] as! [Any])
//            coupleValues["anniDate"] = FieldValue.arrayUnion(coupleValues["anniDate"] as! [Any])
//            self.firebaseService.getDocument(collection: .Users, document: userDTO.uid)
//                .subscribe(onSuccess: { userInfo in
//                    guard let coupleID = userInfo["coupleID"] as? String else{ single(.failure(FireStoreError.unknown)); return }
//                    coupleDocumentID = coupleID
//                    let couplesUpdate = self.firebaseService.updateDocument(collection: .Couples,
//                                                                            document: coupleDocumentID,
//                                                                            values: coupleValues)
//                    let usersUpdate = self.firebaseService.createDocument(collection: .Users,
//                                                                          document: userDTO.uid,
//                                                                          values: userValues)
//                    Single.zip(couplesUpdate, usersUpdate)
//                        .subscribe(onSuccess: { _,_ in
//                            self.firebaseService.setAccessLevel(.complete)
//                                .subscribe(onSuccess: {
//                                    single(.success(()) )
//                                })
//                                .disposed(by: self.disposeBag)
//                        }, onFailure: { error in
//                            single(.failure(error))
//                        })
//                        .disposed(by: self.disposeBag)
//                })
//                .disposed(by: disposeBag)
//            
//            return Disposables.create()
//        }
//        
//    }
    
    public func presetUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void> {
        return firebaseService.getCurrentUser()
            .flatMap { [weak self] successUser -> Single<Void> in
                guard let self else { return .error(FireStoreError.unknown) }

                let userDTO = user.toProfileInsertDTO(uid: successUser.uid, phoneNumber: successUser.phoneNumber ?? "" )
                let dDayDTO = dDay.toDTO()

                UserDefaults.standard.set(userDTO.name, forKey: "name")
                guard let userValues = userDTO.asDictionary,
                      var coupleValues = dDayDTO.asDictionary else {
                    return .error(FireStoreError.unknown)
                }
                

                coupleValues["anniName"] = FieldValue.arrayUnion(coupleValues["anniName"] as? [Any] ?? [])
                coupleValues["anniDate"] = FieldValue.arrayUnion(coupleValues["anniDate"] as? [Any] ?? [])

                return self.firebaseService.getDocument(collection: .Users, document: userDTO.uid)
                    .flatMap { userInfo in
                        guard let coupleID = userInfo["coupleID"] as? String else {
                            return .error(FireStoreError.unknown)
                        }

                        let couplesUpdate = self.firebaseService.updateDocument(
                            collection: .Couples,
                            document: coupleID,
                            values: coupleValues
                        )

                        let usersUpdate = self.firebaseService.createDocument(
                            collection: .Users,
                            document: userDTO.uid,
                            values: userValues
                        )

                        return Single.zip(couplesUpdate, usersUpdate)
                            .flatMap { _, _ in
                                return self.firebaseService.setAccessLevel(.complete)
                            }
                    }
            }
    }

    public func getUserInfo(_ uid: String) -> Observable<UserModel> {
        return self.firebaseService.getDocument(collection: .Users, document: uid)
            .compactMap{ $0.toObject(UserDTO.self)?.toModel() }
            .asObservable()
    }
    
    public func userAccessLevelObserver() {
        
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
    
    public func updateProfileImage(imageData: Data) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(()) }
        
        guard let name = UserDefaults.standard.string(forKey: "name") else{ return Single.just(())}
        
            PushNotificationService.shared.sendPushNotification(title: "MeloMeter", body: "\(name)님이 프로필사진을 변경했어요", type: .profile)
        
        return self.firebaseService.uploadImage(filePath: uid, data: imageData)
            .flatMap{ url in
                return self.firebaseService.updateDocument(collection: .Users, document: uid, values: ["profileImagePath": url] as? [String: Any] ?? [:])
            }
    }
    
    public func downloadImage(url: String) -> Single<Data?> {
        return self.firebaseService.downloadImage(urlString: url)
    }
    
    public func updateUserInfo(value: [String: String]) -> Single<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return Single.just(())}
        if value.first?.key == "birth" {
            return self.setAnniversaries(uid: uid, birth: value["birth"] ?? "")
                .flatMap { _ in
                    return self.firebaseService.updateDocument(collection: .Users,
                                                               document: uid,
                                                               values: value.asDictionary ?? [:])
                }
            
        }else {
            //상태메시지 변경시
            guard let name = UserDefaults.standard.string(forKey: "name") else{ return Single.just(())}
            if value.first?.key == "stateMessage" {
                PushNotificationService.shared.sendPushNotification(title: "MeloMeter", body: "\(name)님이 상태메세지를 업데이트 했어요", type: .profile)
            }else if value.first?.key == "name" {
                PushNotificationService.shared.sendPushNotification(title: "MeloMeter", body: "\(name)님이 이름을 업데이트 했어요", type: .profile)
            }
            
            return self.firebaseService.updateDocument(collection: .Users,
                                                       document: uid,
                                                       values: value.asDictionary ?? [:])
        }
    }
    
    private func setAnniversaries(uid: String, birth: String) -> Single<Void> {
        return Single.create{ single in
            guard let userName = UserDefaults.standard.string(forKey: "name") else{ return Disposables.create()}
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
    
    public func signOut() -> Single<Void> {
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
    
    public func dropOut() -> Single<Void> {
        guard let user = Auth.auth().currentUser else {
            return .error(FireStoreError.unknown)
        }
        
        return Single.create { single in
            user.delete { error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                single(.success(()))
                
            }
            return Disposables.create()
        }
    }
    
    public func withdrawal(uid: String) -> Single<Void> {
        return Single.create{ single in
            self.getUserInfo(uid)
                .subscribe(onNext: { userInfo in
                    self.firebaseService.deleteImageFromProfileStorage(imageURL: userInfo.profileImage ?? "")
                        .subscribe(onSuccess: {
                            self.firebaseService.deleteDocuments(
                                collections: [
                                    (.Users, uid),
                                    (.Locations, uid),
                                    (.Alarm, uid)
                                ]
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
    
    public func removeOtherData(uid: String) -> Single<Void> {
        return Single.create{ single in
            self.getUserInfo(uid)
                .withUnretained(self)
                .subscribe(onNext: { owner, userInfo in
                    let coupleID = userInfo.coupleID ?? ""
                    let data = ["name", "otherUid", "otherUserName", "coupleID", "otherInviteCode", "otherFcmToken"]
                    for key in data {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                    let deleteProfileImage = owner.firebaseService
                        .deleteImageFromProfileStorage(imageURL: userInfo.profileImage ?? "")

                    var updateData: [String: Any] = [:]
                    let fieldsToDelete = ["coupleID",
                                          "name",
                                          "otherFcmToken",
                                          "otherUid",
                                          "profileImagePath",
                                          ]
                    for field in fieldsToDelete {
                        updateData[field] = FieldValue.delete()
                    }
                    updateData.updateValue("", forKey: "stateMessage")
                    
                    let updateUserInfo = owner.firebaseService
                        .updateDocument(collection: .Users,
                                        document: uid,
                                        values: updateData
                        )

                    let filePathArray = owner.chatRepository
                        .getChatImagesURL(coupleID: coupleID)

                    owner.chatRepository
                        .getChatImagesURL(coupleID: coupleID)
                        .subscribe(onSuccess: { st in
                        }, onFailure: { error in
                        })
                        .disposed(by: owner.disposeBag)

                    Single.zip(deleteProfileImage, updateUserInfo, filePathArray)
                        .subscribe(onSuccess: { _, _, filePathArray in
                            self.firebaseService.deleteImageFromChatStorage(filePath: filePathArray)
                                .subscribe(onSuccess: { _ in
                                    self.firebaseService
                                        .deleteDocuments(
                                            collections: [
                                                (.Locations, uid),
                                                (.Alarm, uid),
                                                (.Couples, coupleID),
                                                (.Chat, coupleID),
                                            ]
                                        )
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
                        .disposed(by: owner.disposeBag)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }

    }

    //fcm토큰 업데이트
    public func updateFcmToken(fcmToken: String) {
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
    
    public func changeAccessLevel(otherUid: String) -> Single<Void> {
        let myAccessLevel = self.firebaseService
            .setAccessLevel(.start)
        let otherAccessLevel = self.firebaseService
            .updateDocument(
                collection: .Users,
                document: otherUid,
                values: ["accessLevel": AccessLevel.authenticated.rawValue]
            )
        
        return Single.zip(myAccessLevel, otherAccessLevel)
            .map({ _ in })
    }
}
