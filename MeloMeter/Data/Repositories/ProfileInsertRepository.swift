//
//  ProfileInsertRepository.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation
import Firebase
import RxSwift
import FirebaseFirestore

class ProfileInsertRepository: ProfileInsertRepositoryP {
    
    let defaultFirebaseService = DefaultFirebaseService()
    let disposeBag = DisposeBag()
    
    // 사용자 정보 데이터베이스 저장
    func insertUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            var coupleDocumentID = ""
            //모델객체 -> DTO객체
            let userDTO = user.toProfileInsertDTO()
            let dDayDTO = dDay.toDTO()
            guard let userValues = userDTO.asDictionary, var coupleValues = dDayDTO.asDictionary else { return Disposables.create() }
            coupleValues["anniName"] = FieldValue.arrayUnion(coupleValues["anniName"] as! [Any])
            coupleValues["anniDate"] = FieldValue.arrayUnion(coupleValues["anniDate"] as! [Any])
            self.defaultFirebaseService.getDocument(collection: .Users, document: userDTO.uid)
                .subscribe(onSuccess: { userInfo in
                    guard let coupleID = userInfo["coupleID"] as? String else{ single(.failure(FireStoreError.unknown)); return }
                    coupleDocumentID = coupleID
                    let couplesUpdate = self.defaultFirebaseService.updateDocument(collection: .Couples,
                                                                                   document: coupleDocumentID,
                                                                                   values: coupleValues)
                    let usersUpdate = self.defaultFirebaseService.createDocument(collection: .Users,
                                                               document: userDTO.uid,
                                                               values: userValues)
                    Single.zip(couplesUpdate, usersUpdate)
                    .subscribe(onSuccess: { _,_ in
                        self.defaultFirebaseService.setAccessLevel("Complete")
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
    
}
