//
//  UploadPlaceRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation
import RxSwift
#if canImport(Domain)
import Domain
#endif

public final class CouplePlaceRepo: CouplePlaceRepoP {
    
    public let firebaseService: FirebaseService
    public var disposeBag: DisposeBag
    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    public func getAllPlaces() -> Single<[CouplePlaceModel?]> {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Single.error(NSError(domain: "", code: -1))}
        
        return self.firebaseService.getDocFromSubCollection(firstCollection: .Couples, subCollection: .DatePlaces, document: coupleDocumentID).map { dic in
            return dic.map { value in
                guard
                    let category = value["category"] as? String, let name = value["name"] as? String, let desc = value["description"] as? String, let mapX = value["mapX"] as? Double, let mapY = value["mapY"] as? Double, let roadAddress = value["roadAddress"] as? String, let address = value["address"] as? String, let imagesURLs = value["imageUrls"] as? [String], let uuid = value["uuid"] as? String, let createdAt = value["createdAt"] as? String else { return nil }
                return CouplePlaceModel(category: category, name: name, description: desc, mapX: mapX, mapY: mapY, roadAddress: roadAddress, address: address, imageURLs: imagesURLs,uuid: uuid,createdAt: createdAt)
            }
        }
    }
    
    
    public func uploadPlace(model: CouplePlaceModel) -> Completable {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Completable.error(NSError(domain: "not", code: 404))}
        return uploadMultipleImages(datas: model.imagesDatas ?? [], filePath: "CouplePlaces/\(coupleDocumentID)").flatMapCompletable { urls in
            let dto = CouplePlaceDto(address: model.address, roadAddress: model.roadAddress, uuid: UUID().uuidString, title: model.category, name: model.name, description: model.description, mapX: model.mapX, mapY: model.mapY, imageUrls: urls, createdAt: Date.now.toString(type: .yearToDay), category: model.category)
            
            return  self.firebaseService.createDocToSubcollection(firstCollection: .Couples, subCollection: .DatePlaces, document: coupleDocumentID, values: dto)
            
        }
    }
    
    public func delPlace(uuid: String) -> Completable {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {return Completable.error(NSError(domain: "not", code: 404))}
        return firebaseService.deleteDocument(firstCollection: .Couples, subCollection: .DatePlaces, document: coupleDocumentID, uuid: uuid)
    }
}
extension CouplePlaceRepo {
    public func uploadMultipleImages(datas: [Data], filePath: String) -> Single<[String]> {
        let uploadSingles = datas.map { firebaseService.uploadImage(filePath: "\(filePath)/\(UUID().uuidString)", data: $0) }
        return Single.zip(uploadSingles)
    }
    
    
    
}

public final class DatePlanRepo: DatePlanRepoP {
    public let firebaseService: FirebaseService
    public var disposeBag: DisposeBag

    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }

    public func fetchAllPlans() -> Single<[DatePlanModel?]> {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {
            return Single.error(NSError(domain: "", code: -1))
        }
        return self.firebaseService.getDocFromSubCollection(firstCollection: .Couples,
                                                           subCollection: .DatePlans,
                                                           document: coupleDocumentID)
            .map { data in
                return data.map { value in
                    guard
                        let uuid = value["uuid"] as? String,
                        let name = value["name"] as? String,
                        let memo = value["memo"] as? String,
                        let mapX = value["mapX"] as? Double,
                        let mapY = value["mapY"] as? Double,
                        let roadAddress = value["roadAddress"] as? String,
                        let address = value["address"] as? String,
                        let scheduledAt = value["scheduledAt"] as? String,
                        let createdAt = value["createdAt"] as? String,
                        let createdBy = value["createdBy"] as? String
                    else { return nil }

                    let radiusMeters = (value["radiusMeters"] as? Double) ?? Double(value["radiusMeters"] as? Int ?? 300)
                    let dwellSeconds = value["dwellSeconds"] as? Int ?? 180
                    let rawCheckIns = value["checkIns"] as? [String: Any] ?? [:]
                    let checkIns = rawCheckIns.compactMapValues { $0 as? String }
                    let rawArrivals = value["arrivalRecords"] as? [String: Any] ?? [:]
                    let arrivalRecords = rawArrivals.compactMapValues { $0 as? String }
                    let isOnTime = value["isOnTime"] as? Bool
                    let isCompleted = value["isCompleted"] as? Bool
                    let notifyEnabled = value["notifyEnabled"] as? Bool ?? true
                    return DatePlanModel(uuid: uuid,
                                         name: name,
                                         memo: memo,
                                         mapX: mapX,
                                         mapY: mapY,
                                         roadAddress: roadAddress,
                                         address: address,
                                         scheduledAt: scheduledAt,
                                         createdAt: createdAt,
                                         createdBy: createdBy,
                                         notifyEnabled: notifyEnabled,
                                         radiusMeters: radiusMeters,
                                         dwellSeconds: dwellSeconds,
                                         checkIns: checkIns,
                                         arrivalRecords: arrivalRecords,
                                         isOnTime: isOnTime,
                                         isCompleted: isCompleted)
                }
            }
    }

    public func observePlans() -> Observable<[DatePlanModel?]> {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {
            return Observable.error(NSError(domain: "", code: -1))
        }
        return self.firebaseService.observeSubCollection(firstCollection: .Couples,
                                                         subCollection: .DatePlans,
                                                         document: coupleDocumentID)
            .map { data in
                return data.map { value in
                    guard
                        let uuid = value["uuid"] as? String,
                        let name = value["name"] as? String,
                        let memo = value["memo"] as? String,
                        let mapX = value["mapX"] as? Double,
                        let mapY = value["mapY"] as? Double,
                        let roadAddress = value["roadAddress"] as? String,
                        let address = value["address"] as? String,
                        let scheduledAt = value["scheduledAt"] as? String,
                        let createdAt = value["createdAt"] as? String,
                        let createdBy = value["createdBy"] as? String
                    else { return nil }

                    let radiusMeters = (value["radiusMeters"] as? Double) ?? Double(value["radiusMeters"] as? Int ?? 300)
                    let dwellSeconds = value["dwellSeconds"] as? Int ?? 180
                    let rawCheckIns = value["checkIns"] as? [String: Any] ?? [:]
                    let checkIns = rawCheckIns.compactMapValues { $0 as? String }
                    let rawArrivals = value["arrivalRecords"] as? [String: Any] ?? [:]
                    let arrivalRecords = rawArrivals.compactMapValues { $0 as? String }
                    let isOnTime = value["isOnTime"] as? Bool
                    let isCompleted = value["isCompleted"] as? Bool
                    let notifyEnabled = value["notifyEnabled"] as? Bool ?? true
                    return DatePlanModel(uuid: uuid,
                                         name: name,
                                         memo: memo,
                                         mapX: mapX,
                                         mapY: mapY,
                                         roadAddress: roadAddress,
                                         address: address,
                                         scheduledAt: scheduledAt,
                                         createdAt: createdAt,
                                         createdBy: createdBy,
                                         notifyEnabled: notifyEnabled,
                                         radiusMeters: radiusMeters,
                                         dwellSeconds: dwellSeconds,
                                         checkIns: checkIns,
                                         arrivalRecords: arrivalRecords,
                                         isOnTime: isOnTime,
                                         isCompleted: isCompleted)
                }
            }
    }

    public func savePlan(model: DatePlanModel) -> Completable {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {
            return Completable.error(NSError(domain: "not", code: 404))
        }
        let dto = DatePlanDto(uuid: model.uuid,
                              name: model.name,
                              memo: model.memo,
                              mapX: model.mapX,
                              mapY: model.mapY,
                              roadAddress: model.roadAddress,
                              address: model.address,
                              scheduledAt: model.scheduledAt,
                              createdAt: model.createdAt,
                              createdBy: model.createdBy,
                              notifyEnabled: model.notifyEnabled,
                              radiusMeters: model.radiusMeters,
                              dwellSeconds: model.dwellSeconds,
                              checkIns: model.checkIns,
                              arrivalRecords: model.arrivalRecords,
                              isOnTime: model.isOnTime,
                              isCompleted: model.isCompleted)
        return self.firebaseService.createDocToSubcollection(firstCollection: .Couples,
                                                             subCollection: .DatePlans,
                                                             document: coupleDocumentID,
                                                             values: dto)
    }

    public func deletePlan(uuid: String) -> Completable {
        guard let coupleDocumentID = UserDefaults.standard.string(forKey: "coupleID") else {
            return Completable.error(NSError(domain: "not", code: 404))
        }
        return self.firebaseService.deleteDocument(firstCollection: .Couples,
                                                   subCollection: .DatePlans,
                                                   document: coupleDocumentID,
                                                   uuid: uuid)
    }
}
