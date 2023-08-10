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
    
    private let firebaseService: FireStoreService
    private var userModel: UserModel
    private var logInStatus: LogInStatus = .none
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.userModel = UserModel(name: nil, birth: nil)
    }
    
    //전화번호 전송, 인증ID 저장
    func sendNumber(phoneNumber: String?) -> Single<LogInStatus> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            guard let number = phoneNumber else { return Disposables.create() }
            self.userModel.phoneNumber = "+82 \(number.components(separatedBy: "-").joined())"

            PhoneAuthProvider.provider()
                .verifyPhoneNumber(self.userModel.phoneNumber ?? "", uiDelegate: nil) { (verificationID, error) in
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
                        self.firebaseService.setAccessLevel("Authenticated")
                            .subscribe(onSuccess: {
                                single(.success(inviteCode))
                            })
                            .disposed(by: self.disposeBag)
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
            self.firebaseService.getCurrentUser()
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
            self.firebaseService.createDocument(collection: .Users,
                                                       document: dto.uid,
                                                       values: values)
            .subscribe(onSuccess: {
                single(.success(inviteCode))
                UserDefaults.standard.set("\(inviteCode)", forKey: "inviteCode")
                UserDefaults.standard.set("\(uid)", forKey: "uid")
                UserDefaults.standard.set("\(phoneNumber)", forKey: "phoneNumber")
            }, onFailure: { error in
                single(.failure(error))
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
            
            let date = Date().toString(type: .timeStamp)
            let inviteCode = code.components(separatedBy: " ").joined()
            firebaseService.getCurrentUser()
                .flatMap{ user -> Single<Void> in
                    return self.firebaseService.getDocument(collection: .Users, field: "inviteCode", values: [inviteCode])
                        .flatMap{ data -> Single<Void> in
                            guard !data.isEmpty else{ return Single.just(()) }
                            guard let uid2 = data.last?["uid"] as? String else{ return Single.just(()) }
                            UserDefaults.standard.set("\(uid2)", forKey: "uid2")
                            let updateMyDB = self.firebaseService.updateDocument(collection: .Users, document: user.uid, values: ["otherUid": uid2])
                            let updateOtherDB = self.firebaseService.updateDocument(collection: .Users, document: uid2, values: ["otherUid": user.uid])
                            
                            return Single.zip(updateMyDB, updateOtherDB)
                                .flatMap({ _,_ -> Single<Void> in
                                    return self.firebaseService.createDocument(collection: .Couples, document: "", values: ["coupleCreatedAt" : date])
                                })
                            
                        }
                }
                .subscribe(onSuccess: {
                    guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
                    guard let uid2 = UserDefaults.standard.string(forKey: "uid2") else{ return }
                    guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleDocumentID") else{ return }
                    let update1 = self.firebaseService.updateDocument(collection: .Users, document: uid, values: ["coupleID" : coupleDocumentID])
                    let update2 = self.firebaseService.updateDocument(collection: .Users, document: uid2, values: ["coupleID" : coupleDocumentID])
                    let updateAccessLevel = self.firebaseService.setAccessLevel("CoupleCombined")
                    let updateOtherAccessLevel = self.firebaseService.updateDocument(collection: .Users, document: uid2, values: ["accessLevel" : "CoupleCombined"])
                    
                    Single.zip(update1, update2, updateAccessLevel, updateOtherAccessLevel)
                        .subscribe(onSuccess: { _, _, _, _ in
                            single(.success(()))
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
