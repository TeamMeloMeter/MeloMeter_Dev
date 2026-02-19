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
import Domain

public class CoupleRepository: CoupleRepositoryP {
    
    public var firebaseService: FirebaseService
    public var disposeBag: DisposeBag
    public var coupleModel: PublishSubject<CoupleModel?>
    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.coupleModel = PublishSubject()
        self.disposeBag = DisposeBag()
    }
    
    public func getCoupleID() -> Single<String> {
        if let coupleID = UserDefaults.standard.string(forKey: "coupleID") {
            return Single.just(coupleID)
        }else {
            return self.firebaseService.getCurrentUser()
                .flatMap{ user -> Single<String> in
                    return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .flatMap{ data -> Single<String> in
                            guard let id = data["coupleID"] as? String else{ return Single.just("") }
                            UserDefaults.standard.set(id, forKey: "coupleID")
                            return Single.just(id)
                        }    
                }
        }
    }
    
    public func getCoupleDocument() -> Single<CoupleModel> {
        return self.getCoupleID()
            .flatMap{ coupleID -> Single<CoupleModel> in
                return self.firebaseService.getDocument(collection: .Couples, document: coupleID)
                    .compactMap{ $0.toObject(CoupleDTO.self)?.toModel() }
                    .asObservable()
                    .asSingle()
            }
    }
    
    public func setAnniversaries(data: [String]) -> Single<Void> {
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
    
    public func couplesObserver() {
        getCoupleID()
            .subscribe(onSuccess: { coupleID in
                self.firebaseService.observer(collection: .Couples, document: coupleID)
                    .map{ $0.toObject(CoupleDTO.self)?.toModel() ?? CoupleModel(firstDay: Date(), anniversaries: []) }
                    .asObservable()
                    .subscribe(onNext: { [weak self] model in
                        self?.coupleModel.onNext(model)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    public func disconnect() -> Single<Date> {
        return self.getCoupleID()
            .flatMap{ coupleID -> Single<Date> in
                return self.firebaseService.updateDocument(collection: .Couples,
                                                           document: coupleID,
                                                           values: ["disconnectedDate": Date().toString(type: .yearToDay)]
                                                           )
                    .flatMap{ _ -> Single<Date> in
                        return Single.just(Date())
                    }
            }
    }
    
    public func recovery(deadlineDate: Date) -> Single<Bool> {
        if deadlineDate < Date() {
            return Single.just(false)
        }else {
            return self.getCoupleID()
                .flatMap{ coupleID in
                    return self.firebaseService.updateDocument(collection: .Couples,
                                                               document: coupleID,
                                                               values: ["disconnectedDate": ""]
                                                               )
                    .map{ _ -> Bool in
                        return true
                    }
                }
        }
    }
    
    public func withdrawalAlarm(otherUid: String) -> Single<Void> {
        guard !otherUid.isEmpty else {
            return Single.just(())
        }
        return self.firebaseService.updateDocument(collection: .Users,
                                            document: otherUid,
                                            values: ["coupleID": "",
                                                     "otherUid": "",
                                                     "birth": "",
                                                     "name": "",
                                                     "accessLevel": "authenticated"
                                                    ]
        )
    }
    
}
