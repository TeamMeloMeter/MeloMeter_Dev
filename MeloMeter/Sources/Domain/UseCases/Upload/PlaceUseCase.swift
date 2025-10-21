//
//  PlaceUseCase.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import RxSwift
protocol PlaceUseCase {
    func upload(model: CouplePlaceModel) -> Completable
    func fetchAll() -> Single<[CouplePlaceModel]>
    func delPlace(model: CouplePlaceModel) -> Completable
}
final class PlaceUseCaseImpl: PlaceUseCase {
  
    private let repository: CouplePlaceRepoP

    init(repository: CouplePlaceRepoP) {
        self.repository = repository
    }
    func fetchAll() -> Single<[CouplePlaceModel]> {
        return repository.getAllPlaces()  .map { optionalModels in
            optionalModels.compactMap { $0 }
          }
    }
    func upload(model: CouplePlaceModel) -> Completable {
        return repository.uploadPlace(model: model)
    }
    func delPlace(model: CouplePlaceModel) -> Completable {
        return repository.delPlace(uuid: model.uuid!)
    }
    
    
}
