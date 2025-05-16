//
//  SharedDataRepoP.swift
//  MeloMeter
//
//  Created by 양승완 on 4/23/25.
//

import Foundation
import RxSwift

protocol SearchRepoP {
    func searchNaverAPI(text: String) -> Single<[SearchedModel]> 
}
