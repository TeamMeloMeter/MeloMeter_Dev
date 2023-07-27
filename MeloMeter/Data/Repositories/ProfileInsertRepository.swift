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
    func insertUserInfo(user: UserModel) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            //모델객체 -> DTO객체
            let userDTO = user.toProfileInsertDTO()
            let userDic = [""]
            guard let values = userDTO.asDictionary else { return Disposables.create() }
            self.defaultFirebaseService.createDocument(collection: .Users,
                                                       document: userDTO.uid,
                                                       values: values)
            .subscribe(onSuccess: {
                UserDefaults.standard.set(3, forKey: "logInLevel")
                single(.success(()) )
            }, onFailure: { error in
                single(.failure(error))
            })
            .disposed(by: disposeBag)
            
            return Disposables.create()
        }
        
    }
    
}
