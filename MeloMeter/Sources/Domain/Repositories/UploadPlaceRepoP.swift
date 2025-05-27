//
//  UploadPlaceRepoP.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//
import RxSwift
protocol UploadPlaceRepoP {
    func uploadPlace(model: CouplePlaceModel) -> Completable 
}
