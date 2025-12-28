//
//  UploadPlaceRepoP.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//
import RxSwift
public protocol CouplePlaceRepoP {
    func uploadPlace(model: CouplePlaceModel) -> Completable
    func getAllPlaces() -> Single<[CouplePlaceModel?]>
    func delPlace(uuid: String) -> Completable
}
