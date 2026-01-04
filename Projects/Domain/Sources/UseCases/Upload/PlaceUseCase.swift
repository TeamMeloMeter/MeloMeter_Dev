//
//  PlaceUseCase.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation
import RxSwift

public protocol PlaceUseCase {
    func upload(model: CouplePlaceModel) -> Completable
    func fetchAll() -> Single<[CouplePlaceModel]>
    func delPlace(model: CouplePlaceModel) -> Completable
}
public final class PlaceUseCaseImpl: PlaceUseCase {
  
    private let repository: CouplePlaceRepoP

    public init(repository: CouplePlaceRepoP) {
        self.repository = repository
    }
    public func fetchAll() -> Single<[CouplePlaceModel]> {
        return repository.getAllPlaces()  .map { optionalModels in
            optionalModels.compactMap { $0 }
          }
    }
    public func upload(model: CouplePlaceModel) -> Completable {
        return repository.uploadPlace(model: model)
    }
    public func delPlace(model: CouplePlaceModel) -> Completable {
        return repository.delPlace(uuid: model.uuid!)
    }
    
    
}

public protocol DatePlanUseCase {
    func fetchAll() -> Single<[DatePlanModel]>
    func observePlans() -> Observable<[DatePlanModel]>
    func savePlan(model: DatePlanModel) -> Completable
    func deletePlan(uuid: String) -> Completable
}

public final class DatePlanUseCaseImpl: DatePlanUseCase {
    private let repository: DatePlanRepoP

    public init(repository: DatePlanRepoP) {
        self.repository = repository
    }

    public func fetchAll() -> Single<[DatePlanModel]> {
        return repository.fetchAllPlans()
            .map { optionalModels in
                optionalModels.compactMap { $0 }
            }
    }

    public func observePlans() -> Observable<[DatePlanModel]> {
        return repository.observePlans()
            .map { optionalModels in
                optionalModels.compactMap { $0 }
            }
    }

    public func savePlan(model: DatePlanModel) -> Completable {
        return repository.savePlan(model: model)
    }

    public func deletePlan(uuid: String) -> Completable {
        return repository.deletePlan(uuid: uuid)
    }
}
