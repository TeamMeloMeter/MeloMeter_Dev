//
//  DdayRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import Foundation
import Firebase
import RxSwift

class DdayRepository: DdayRepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
        
    }
    
    func getDdays() -> Single<DdayModel?> {
        return self.firebaseService.getCurrentUser()
            .flatMap{ user -> Single<DdayModel?> in
                return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                    .flatMap{ data -> Single<DdayModel?> in
                        guard let id = data["coupleID"] as? String else{ return Single.just(DdayModel(firstDay: Date(), anniversaries: [])) }
                        return self.firebaseService.getDocument(collection: .Couples, document: id)
                            .map{ $0.toObject(DdayDTO.self)?.toModel() }
                            
                    }
            }
    }
    
    func anniversariesObserver() {
        
    }
    
    func setFirstDay() {
        
    }
    
    func setAnniversaries() {
        
    }
    
}
