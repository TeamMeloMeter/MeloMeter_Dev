//
//  MapSearchVM.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import RxSwift

struct ResultModel {
    let name: String
    let lat: Double
    let long: Double
    
}

class MapSearchVM {
    weak var coordinator: MainCoordinator?
    private var mainUseCase: MainUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchText: Observable<String>
    
        
    }
    
    struct Output {
        let resultModels = BehaviorSubject<ResultModel?>(value: nil)
    }
    
    
    init(coordinator: MainCoordinator, mainUseCase: MainUseCase) {
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.searchText.subscribe(onNext: { [weak self] text in
            guard let self else {return}
            
            
        }).disposed(by: disposeBag)
        
        output.resultModels.onNext(<#T##element: ResultModel?##ResultModel?#>)
     
        return output
    }
    
}
