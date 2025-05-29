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
}
final class PlaceUseCaseImpl: PlaceUseCase {
    private let repository: UploadPlaceRepoP

    init(repository: UploadPlaceRepoP) {
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
    
}
