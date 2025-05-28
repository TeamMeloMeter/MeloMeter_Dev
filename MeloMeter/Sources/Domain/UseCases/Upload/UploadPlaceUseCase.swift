//
//  UploadPlaceUseCase.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import RxSwift
protocol UploadPlaceUseCase {
    func execute(model: CouplePlaceModel) -> Completable

}
final class UploadPlaceUseCaseImpl: UploadPlaceUseCase {
    private let repository: UploadPlaceRepoP

    init(repository: UploadPlaceRepoP) {
        self.repository = repository
    }

    func execute(model: CouplePlaceModel) -> Completable {
        return repository.uploadPlace(model: model)
    }
}
