//
//  AlarmUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation
import RxSwift
import RxRelay

public class SearchUseCase {
    
    // MARK: - Property
    private let searchRepo: SearchRepoP
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    public init(searchRepo: SearchRepoP) {
        self.searchRepo = searchRepo
    }
    
    
    public func getResults(text: String) -> Single<[SearchedModel]> {
        return searchRepo.searchNaverAPI(text: text)
        
    }
    
  
}
