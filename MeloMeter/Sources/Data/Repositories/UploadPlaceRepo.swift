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
    func getAllPlaces() -> Single<[CouplePlaceModel?]> {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Single.error(NSError(domain: "", code: -1))}
        
        return self.firebaseService.getDocFromSubCollection(firstCollection: .Couples, subCollection: .DatePlaces, document: coupleDocumentID).map { dic in
            return dic.map { value in
                
                guard
                    let category    = value["category"]    as? String,
                    let name        = value["name"]        as? String,
                    let desc        = value["description"] as? String,
                    let mapX        = value["mapX"]        as? Double,
                    let mapY        = value["mapY"]        as? Double,
                    let roadAddress = value["roadAddress"] as? String,
                    let address     = value["address"]     as? String,
                    let imagesURLs   = value["imageUrls"]  as? [String]
                        
                else { return nil }
                return CouplePlaceModel(category: category, name: name, description: desc, mapX: mapX, mapY: mapY, roadAddress: roadAddress, address: address, imageURLs: imagesURLs)
            }
        }
    }
    
    
    func uploadPlace(model: CouplePlaceModel) -> Completable {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Completable.error(NSError(domain: "not", code: 404))}
        return uploadMultipleImages(datas: model.imagesDatas ?? [], filePath: "CouplePlaces/\(coupleDocumentID)").flatMapCompletable { urls in
            let dto = CouplePlaceDto(address: model.address, roadAddress: model.roadAddress, uuid: UUID().uuidString, title: model.category, name: model.name, description: model.description, mapX: model.mapX, mapY: model.mapY, imageUrls: urls, createdAt: Date.now.toString(type: .yearToDay), category: model.category)
            
            return  self.firebaseService.createDocToSubcollection(firstCollection: .Couples, subCollection: .DatePlaces, document: coupleDocumentID, values: dto)
            
        }
    }
}
extension UploadPlaceRepo {
    func uploadMultipleImages(datas: [Data], filePath: String) -> Single<[String]> {
        let uploadSingles = datas.map { firebaseService.uploadImage(filePath: filePath, data: $0) }
        return Single.zip(uploadSingles) // → Single<[String]>
    }
    
    
    
}
