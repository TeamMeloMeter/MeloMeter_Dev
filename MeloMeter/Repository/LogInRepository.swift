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
class LogInRepository {
    
    let defaultFirebaseService = DefaultFirebaseService()
    
    var userInfoModel = UserInfoModel()
    var logInStatus: LogInStatus = .none
    let disposeBag = DisposeBag()
    
    //전화번호 전송, 인증ID 저장
    func sendNumber(phoneNumber: String?) -> Single<LogInStatus> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            guard let number = phoneNumber else { return Disposables.create() }
            self.userInfoModel.phoneNumber = "+82 \(number.components(separatedBy: "-").joined())"
            
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(self.userInfoModel.phoneNumber ?? "", uiDelegate: nil) { (verificationID, error) in
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
    func inputVerificationCode(verificationCode: String?) -> Single<String> {
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
                    self.userInFirestore().subscribe(onSuccess: { inviteCode in
                        single(.success(inviteCode))
                    }, onFailure: { error in
                        single(.failure(error))
                    }).disposed(by: self.disposeBag)
                }
            }
            return Disposables.create()
        }

    }

    //로그인된 사용자의 uid, phoneNumber 받아서 storeUserInFirestore 호출
    func userInFirestore() -> Single<String> {
        return Single.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            var uid = ""
            var phoneNumber = ""
            self.defaultFirebaseService.getCurrentUser()
                .subscribe(onSuccess: { user in
                    uid = user.uid
                    guard let number = user.phoneNumber else{ return }
                    phoneNumber = number
                })
                .disposed(by: disposeBag)
            let createdAt = Date()
            let inviteCode = "\(phoneNumber.suffix(4) + createdAt.toString(type: Date.Format.timeStamp).filter{ $0.isNumber }.map{ String($0) }.suffix(4).joined())"
            let dto = LogInDTO(uid: uid,
                               phoneNumber: phoneNumber,
                               createdAt: createdAt.toString(type: Date.Format.timeStamp),
                               inviteCode: inviteCode)
            guard let values = dto.asDictionary else { return Disposables.create() }
            self.defaultFirebaseService.createDocument(collection: .Users,
                                                       document: dto.uid,
                                                       values: values)
            .subscribe(onSuccess: {
                single(.success(inviteCode))
                UserDefaults.standard.set("\(inviteCode)", forKey: "inviteCode")
            }, onFailure: { error in
                single(.failure(error))
            })
            .disposed(by: disposeBag)
    
            return Disposables.create()
        }
    }
    
    
    // 내 usersCollection 문서 get
    func getUserLoginInfo() -> Single<LogInModel?> {
        return defaultFirebaseService.getCurrentUser()
            .flatMap { user -> Single<LogInModel?> in
                let documentID = user.uid
                return self.defaultFirebaseService.getDocument(collection: .Users, document: documentID)
                    .map{ $0.toObject(LogInDTO.self)?.toModel() }
            }
    }


    //커플 등록 로직
    func combineCouple(code: String) -> Single<Void> {
        return Single.create{ [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let date = Date().toString(type: .timeStamp)
            let inviteCode = code.components(separatedBy: " ").joined()
            defaultFirebaseService.getCurrentUser()
                .flatMap{ user -> Single<Void> in
                    return self.defaultFirebaseService.getDocument(collection: .Users, field: "inviteCode", values: [inviteCode])
                        .flatMap{ data -> Single<Void> in
                            guard !data.isEmpty else{
                                single(.failure(CombineError.falure)); return Single.just(())}
                            guard let phoneNumber1 = user.phoneNumber, let uid2 = data.last?["uid"] as? String, let phoneNumber2 = data.last?["phoneNumber"] as? String else{ return Single.just(()) }
                            
                            let dto = CoupleCombineDTO(uid1: user.uid,
                                                phoneNumber1: phoneNumber1,
                                                uid2: uid2,
                                                phoneNumber2: phoneNumber2,
                                                createdAt: date)
                            
                            guard let values = dto.asDictionary else{ return Single.just(()) }
                            
                            return self.defaultFirebaseService.createDocument(collection: .Couples, document: "", values: values)
                        }
                }
                .subscribe(onSuccess: {
                    single(.success(()))
                }, onFailure: { error in
                    single(.failure(error))
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
}
//self.defaultFirebaseService.getCurrentUser(field: "UID")
//                .withUnretained(self)
//                .subscribe(onNext: { id in
//                    guard let uid1 = id.1 else{ return }
//                    addDataDic["UID1"] = uid1
//                    //Phone1 저장
//                    self.defaultFirebaseService.getCurrentUser(field: "PhoneNumber")
//                        .withUnretained(self)
//                        .subscribe(onNext: { number in
//                            guard let phoneNumber = number.1 else{ return }
//                            addDataDic["PhoneNumber1"] = phoneNumber
//                            self.defaultFirebaseService.getDocument(collection: .usersCollection, field: "CoupleCode", values: [code])
//                                .map{ [FirebaseData] -> Single<Void> in
//
//                                }
//                                .subscribe(onSuccess: { data in // [FirebaseData]
//                                    addDataDic["UID2"] = data.last?["UID"]
//                                    addDataDic["PhoneNumber2"] = data.last?["PhoneNumber"]
//                                    self.defaultFirebaseService.createDocument(collection: .couplesCollection, document: "", values: addDataDic)
//                                        .subscribe(onSuccess: {
//                                            single(.success(()))
//                                        }, onFailure: { error in
//                                            single(.failure(error))
//                                        }).disposed(by: self.disposeBag)
//                                }, onFailure: { error in
//                                    single(.failure(error))
//                                }).disposed(by: self.disposeBag)
//                        }).disposed(by: self.disposeBag)
//                }).disposed(by: disposeBag)
