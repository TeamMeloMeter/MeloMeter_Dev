//
//  UploadPlaceRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation
import RxSwift

final class UploadPlaceRepo: UploadPlaceRepoP {
    let firebaseService: FirebaseService
    var disposeBag: DisposeBag
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    func uploadPlace(model: CouplePlaceModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {
                completable(.error(NSError(domain: "MissingCoupleID", code: -1)))
                return Disposables.create()
            }

            let disposable = self.uploadMultipleImages(datas: model.images, filePath: "CouplePlaces/\(coupleDocumentID)")
                .flatMapCompletable { urls in
                    let dto = CouplePlaceDto(uuid: UUID().uuidString, title: model.category, name: model.name,description: model.description,latitude: model.mapX,longitude: model.mapY,imageUrls: urls,createdAt: Date.now.toString(type: .yearToDay))

                    return self.firebaseService.createDocToSubcollection(
                        firstCollection: .Couples,
                        subCollection: .DatePlaces,
                        document: coupleDocumentID,
                        values: dto
                    )
                }
                .subscribe(
                    onCompleted: { completable(.completed) },
                    onError: { completable(.error($0)) }
                )

            return Disposables.create {
                disposable.dispose()
            }
        }
    }


//    func uploadPlace(model: CouplePlaceModel) -> Completable {
//        
//        Completable.create { [weak self] completable in
//            guard let self, let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Disposables.create()}
//        
//           
//            uploadMultipleImages(datas: model.images, filePath: "CouplePlaces/\(coupleDocumentID)").map { urls in
//                
//                let dto = CouplePlaceDto(uuid: UUID().uuidString, title: model.category, name: model.name, description: model.description, latitude: model.mapX, longitude: model.mapY, imageUrls: urls, createdAt: Date.now.toString(type: .yearToDay))
//                
//                return  self.firebaseService.createDocToSubcollection(firstCollection: .Couples, subCollection: .DatePlaces, document: dto.uuid, values: dto)
//            }.subscribe(onSuccess: { com in
//                print("completed??????!??!?!?!?")
//                completable(.completed)
//                
//            }, onFailure: { error in
//                completable(.error(error))
//            }).disposed(by: disposeBag)
//                
//            return Disposables.create { print("uploadPlace Disposed") }
//        }
//        
//        
//    }
}

extension UploadPlaceRepo {
    func uploadMultipleImages(datas: [Data], filePath: String) -> Single<[String]> {
        let uploadSingles = datas.map { firebaseService.uploadImage(filePath: filePath, data: $0) }
        return Single.zip(uploadSingles) // → Single<[String]>
    }
}
