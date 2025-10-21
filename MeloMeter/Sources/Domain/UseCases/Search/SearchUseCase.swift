//
//  AlarmUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import UIKit
import Firebase
import RxSwift
import RxRelay

class SearchUseCase {
    
    // MARK: - Property
    private let searchRepo: SearchRepoP
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init(searchRepo: SearchRepoP) {
        self.searchRepo = searchRepo
    }
    
    
    func getResults(text: String) -> Single<[SearchedModel]> {
        return searchRepo.searchNaverAPI(text: text)
        
    }
    
  
}
