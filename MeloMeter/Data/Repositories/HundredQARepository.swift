//
//  HundredQARepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

class HundredQARepository: HundredQARepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    var coupleModel: PublishSubject<CoupleModel?>
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.coupleModel = PublishSubject()
        self.disposeBag = DisposeBag()
    }
    
    func getCoupleID() -> Single<String> {
        if let coupleID = UserDefaults.standard.string(forKey: "coupleDocumentID") {
            return Single.just(coupleID)
        }else {
            return self.firebaseService.getCurrentUser()
                .flatMap{ user -> Single<String> in
                    return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .flatMap{ data -> Single<String> in
                            guard let id = data["coupleID"] as? String else{ return Single.just("") }
                            UserDefaults.standard.set(id, forKey: "coupleDocumentID")
                            return Single.just(id)
                        }
                        
                }
        }
    }
    
    func getAnswerList() -> Void {
        self.getCoupleID()
            .subscribe(onSuccess: { coupleID in
                self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                    .subscribe(onSuccess: { data in
                        print("커플문서", data)
                    })
            })
    }
    
    func setAnswerList(data: HundredQAModel) -> Single<Void> {
        return self.getCoupleID()
            .flatMap{ coupleID -> Single<Void> in
                self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                    .flatMap{ source -> Single<Void> in
                        
                        return self.firebaseService.updateDocument(collection: .Couples, document: coupleID, values: [:])
                    }
            }
    }
    
    func answerListObserver() {
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
    
    
    
    
    
}
