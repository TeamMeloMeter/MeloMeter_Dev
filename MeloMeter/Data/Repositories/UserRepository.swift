//
//  UserRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/05.
//

import Foundation
import Firebase
import RxSwift
import FirebaseFirestore

class UserRepository: UserRepositoryP {
    
    private var firebaseService: FireStoreService
    private var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    func getUserInfo(_ uid: String) -> Observable<UserDTO> {
        return self.firebaseService.getDocument(collection: .Users, document: uid)
            .map{ $0.toObject(UserDTO.self)! }
            .asObservable()
    }
    
    
}
