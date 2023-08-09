//
//  DdayRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

class CoupleRepository: CoupleRepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    var coupleDocumentID: String = ""
    var anniversaries: PublishRelay<[DdayCellData]>
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
        self.anniversaries = PublishRelay()
    }
    
    func getCoupleModel() -> Single<CoupleModel?> {
        return self.firebaseService.getCurrentUser()
            .flatMap{ user -> Single<CoupleModel?> in
                return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                    .flatMap{ data -> Single<CoupleModel?> in
                        guard let id = data["coupleID"] as? String else{ return Single.just(CoupleModel(firstDay: Date(), anniversaries: [], coupleCreatedAt: Date())) }
                        self.coupleDocumentID = id
                        return self.firebaseService.getDocument(collection: .Couples, document: self.coupleDocumentID)
                            .map{ $0.toObject(CoupleDTO.self)?.toModel() }
                    }
            }
    }
    
    func anniversariesObserver() {
        
//        self.firebaseService.observer(collection: .Couples, document: self.coupleDocumentID)
//            .map{ data -> Bool in
//                if let isCombined = data["accessLevel"] as? String {
//                    if isCombined == "CoupleCombined" {
//                        return true
//                    }
//                }
//                return false
//            }
//            .asObservable()
//            .bind(to: self.combineCheck)
//            .disposed(by: self.disposeBag)
        
    }
    
    func setFirstDay() {
        
    }
    
    func setAnniversaries() {
        
    }
    
}
