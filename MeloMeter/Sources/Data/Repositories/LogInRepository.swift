//
//  LogInRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/08.
//

import Foundation
import Firebase
import RxSwift
import FirebaseFirestore
class LogInRepository: LogInRepositoryP {
    
    private let firebaseService: FirebaseService
    private var logInStatus: LogInStatus = .none
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
    }
    
    //전화번호 전송, 인증ID 저장
    func sendNumber(phoneNumber: String?) -> Single<LogInStatus> {
        return Single.create { single in
            guard let number = phoneNumber else { return Disposables.create() }
            let authPhoneNumber = "+82 \(number.components(separatedBy: "-").joined())"
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(authPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    if let id = verificationID {
                        if id.isEmpty {
                            single(.success(.validationFailed))
                            return
                        }else {
                            UserDefaults.standard.set("\(id)", forKey: "verificationID")
                            single(.success(.requestCompleted))
                            return
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    //인증번호 입력 -> 로그인
    func inputVerificationCode(verificationCode: String?) -> Single<String?> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            guard let code = verificationCode else { return Disposables.create() }
            guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else{ return Disposables.create() }
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: code
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    single(.failure(error))
                }else {
                    self.userInFirestore().subscribe(onSuccess: { state in
                        self.firebaseService.setAccessLevel(state.0)
                            .subscribe(onSuccess: {
                                single(.success(state.1))
                            })
                            .disposed(by: self.disposeBag)
                    }, onFailure: { error in
                        self.firebaseService.setAccessLevel(.none)
                            .subscribe(onSuccess: {
                                single(.success(nil))
                            })
                            .disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
                }
            }
            return Disposables.create()
        }

    }

    //로그인된 사용자의 uid, phoneNumber 받아서 storeUserInFirestore 호출
    func userInFirestore() -> Single<(AccessLevel, String?)> {
        return Single.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            var uid = ""
            var phoneNumber = ""
            self.firebaseService.getCurrentUser()
                .subscribe(onSuccess: { user in
                    uid = user.uid
                    UserDefaults.standard.set("\(uid)", forKey: "uid")
                    guard let number = user.phoneNumber else{ return }
                    phoneNumber = number
                    UserDefaults.standard.set("\(phoneNumber)", forKey: "phoneNumber")
                    guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else{ return }
                    let createdAt = Date()
                    let inviteCode = "\(phoneNumber.suffix(4) + createdAt.toString(type: Date.Format.timeStamp).filter{ $0.isNumber }.map{ String($0) }.suffix(4).joined())"
                    let dto = LogInDTO(fcmToken: fcmToken,
                                       uid: uid,
                                       phoneNumber: phoneNumber,
                                       createdAt: createdAt.toString(type: Date.Format.timeStamp),
                                       inviteCode: inviteCode,
                                       stateMessage: "")
                    
                    self.firebaseService.getDocument(collection: .Users, document: uid)
                        .subscribe(onSuccess: { user in
                            guard let userModel = user.toObject(UserDTO.self)?.toModel() else{ return }
                            if let name = userModel.name {
                                UserDefaults.standard.set(name, forKey: "userName")
                                single(.success((AccessLevel.complete, nil)))
                            }else if let coupleID = userModel.coupleID {
                                UserDefaults.standard.set(coupleID, forKey: "coupleDocumentID")
                                single(.success((AccessLevel.coupleCombined, nil)))
                            }
                        },onFailure: {[weak self] error in
                            guard let values = dto.asDictionary, let self = self else { return }
                            
                            self.firebaseService.createDocument(collection: .Users,
                                                                document: dto.uid,
                                                                values: values)
                            .subscribe(onSuccess: { _ in
                                UserDefaults.standard.set("\(inviteCode)", forKey: "inviteCode")
                                single(.success((.authenticated, inviteCode)))
                            })
                            .disposed(by: self.disposeBag)
                            let geopoint = GeoPoint(latitude: 0, longitude: 0)
                            self.firebaseService.createDocument(collection: .Locations,
                                                                document: uid,
                                                                values: ["location": geopoint])
                            .subscribe(onSuccess: {}).disposed(by: self.disposeBag)
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
        
    }
    
    
    // 내 usersCollection 문서 get
    func getUserLoginInfo() -> Single<LogInModel?> {
        return firebaseService.getCurrentUser()
            .flatMap { user -> Single<LogInModel?> in
                let documentID = user.uid
                return self.firebaseService.getDocument(collection: .Users, document: documentID)
                    .map{ $0.toObject(LogInDTO.self)?.toModel() }
            }
    }


    //커플 등록 로직
    func combineCouple(code: String) -> Single<Void> {
        return Single.create{ [weak self] single in
            guard let self = self else { return Disposables.create() }
            let inviteCode = code.components(separatedBy: " ").joined()
            let currentDate = Date().toString(type: .yearToHour)
            firebaseService.getCurrentUser()
                .flatMap{ user -> Single<Void> in
                    return self.firebaseService.getDocument(collection: .Users, field: "inviteCode", values: [inviteCode])
                        .flatMap{ data -> Single<Void> in
                            guard !data.isEmpty else{ return Single.error(FireStoreError.unknown) }
                            guard let otherUid = data.last?["uid"] as? String else{ return Single.error(FireStoreError.unknown) }
                            if otherUid == user.uid { return Single.error(FireStoreError.unknown) }
                            guard let otherFcmToken = data.last?["fcmToken"] as? String else{ return Single.error(FireStoreError.unknown) }
                            UserDefaults.standard.set("\(otherUid)", forKey: "otherUid")
                            guard let myFcmToken = UserDefaults.standard.string(forKey: "fcmToken") else{ return Single.error(FireStoreError.unknown) }
                            let updateMyDB = self.firebaseService.updateDocument(collection: .Users, document: user.uid, values: ["otherFcmToken": otherFcmToken, "otherUid": otherUid])
                            let updateOtherDB = self.firebaseService.updateDocument(collection: .Users, document: otherUid, values: ["otherFcmToken": myFcmToken, "otherUid": user.uid])
                            
                            return Single.zip(updateMyDB, updateOtherDB)
                                .flatMap({ _,_ -> Single<Void> in
                                    return self.firebaseService.createDocument(collection: .Couples,
                                                                               document: "",
                                                                               values: ["disconnectedDate" : "",
                                                                                        "answersList": ["0": [["date": currentDate]]]
                                                                                       ]
                                                                                )
                                })
                            
                        }
                }
                .subscribe(onSuccess: {
                    guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
                    guard let otherUid = UserDefaults.standard.string(forKey: "otherUid") else{ return }
                    guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleDocumentID") else{ return }
                    let defaultProfileImage = UIImage(named: "defaultProfileImage")!
                    let uploadDefaultImage = self.firebaseService.uploadImage(filePath: uid, image: defaultProfileImage)
                    let uploadDefaultImage2 = self.firebaseService.uploadImage(filePath: otherUid, image: defaultProfileImage)
                    Single.zip(uploadDefaultImage, uploadDefaultImage2)
                        .subscribe(onSuccess: { user1, user2 in
                            let update1 = self.firebaseService.updateDocument(collection: .Users,
                                                                              document: uid,
                                                                              values: ["coupleID": coupleDocumentID,
                                                                                       "profileImagePath": user1]
                            )
                            let update2 = self.firebaseService.updateDocument(collection: .Users,
                                                                              document: otherUid,
                                                                              values: ["coupleID": coupleDocumentID,
                                                                                       "profileImagePath": user2]
                            )
                            let chatDocumentCreate = self.firebaseService.createDocument(collection: .Chat, document: coupleDocumentID, values: ["chatField": []])
                            let myAlarmDocumentCreate = self.firebaseService.createDocument(collection: .Alarm, document: uid, values: ["alarmList": []])
                            let otherAlarmDocumentCreate = self.firebaseService.createDocument(collection: .Alarm, document: otherUid, values: ["alarmList": []])
                            let updateAccessLevel = self.firebaseService.setAccessLevel(.coupleCombined)
                            let updateOtherAccessLevel = self.firebaseService.updateDocument(collection: .Users, document: otherUid, values: ["accessLevel" : "coupleCombined"])
                            
                            Single.zip(update1, update2, chatDocumentCreate, myAlarmDocumentCreate, otherAlarmDocumentCreate, updateAccessLevel, updateOtherAccessLevel)
                                .subscribe(onSuccess: { _, _, _, _, _, _, _ in
                                    single(.success(()))
                                }, onFailure: { error in
                                    single(.failure(error))
                                })
                                .disposed(by: self.disposeBag)
                        })
                        .disposed(by: self.disposeBag)
                }, onFailure: { error in
                    single(.failure(error))
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
}
