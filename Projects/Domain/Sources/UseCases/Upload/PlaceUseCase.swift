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
