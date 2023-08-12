//
//  DdayRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

class CoupleRepository: CoupleRepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    var coupleModel: PublishRelay<CoupleModel>
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.coupleModel = PublishRelay()
        self.disposeBag = DisposeBag()
    }
    
    func getCoupleID() -> Single<String> {
        return self.firebaseService.getCurrentUser()
            .flatMap{ user -> Single<String> in
                return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                    .flatMap{ data -> Single<String> in
                        guard let id = data["coupleID"] as? String else{ return Single.just("") }
                        return Single.just(id)
                    }
            }
    }
    
    func couplesObserver() {
        getCoupleID()
            .subscribe(onSuccess: { coupleID in
                self.firebaseService.observer(collection: .Couples, document: coupleID)
                    .map{ $0.toObject(CoupleDTO.self)?.toModel() ?? CoupleModel(firstDay: Date(), anniversaries: []) }
                    .asObservable()
                    .bind(to: self.coupleModel)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    func setAnniversaries(data: [String]) -> Single<Void> {
        return self.getCoupleID()
            .flatMap{ coupleID -> Single<Void> in
                self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                    .flatMap{ source -> Single<Void> in
                        let dto = source.toObject(CoupleDTO.self)
                        guard let dto = dto else{ return Single.just(()) }
                        var anniName = dto.anniName
                        var anniDate = dto.anniDate
                        anniName.append(data[0])
                        anniDate.append(data[1])
                        let values = ["anniName": anniName, "anniDate": anniDate]
                        return self.firebaseService.updateDocument(collection: .Couples, document: coupleID, values: values)
                    }
            }
    }
    
}
