//
//  MapSearchVM.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import RxSwift
import RxRelay
import RxCocoa

struct ResultModel {
    let name: String
    let lat: Double
    let long: Double
    
}

class MapSearchVM {
    weak var coordinator: MainCoordinator?
    private var searchUseCase: SearchUseCase
    private let searchedModels = BehaviorRelay<[SearchedModel]>(value: [])
    var onLocationSelected = PublishSubject<SearchedModel>()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchText: Observable<String>
        let keyBoardBtnTapped: Observable<Void>
        let tapIdx: Observable<Int>
        let backBtnTapped: Observable<UITapGestureRecognizer>
    }
    
    struct Output {
        let resultModels = BehaviorSubject<[SearchedModel]>(value: [])
    
    }
    
    
    init(coordinator: MainCoordinator, searchUseCase: SearchUseCase) {
        self.coordinator = coordinator
        self.searchUseCase = searchUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapped.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            coordinator?.popViewController()
            
            
        }).disposed(by: disposeBag)
        
        input.keyBoardBtnTapped.withLatestFrom(input.searchText).flatMap({ text in
            self.searchUseCase.getResults(text: text)
        }).subscribe(onNext: { [weak self] in
            guard let self else {return}
            self.searchedModels.accept($0)
            output.resultModels.onNext($0)
        }).disposed(by: disposeBag)
        
        input.tapIdx.subscribe(onNext: { [weak self] idx in
            guard let self else {return}
            onLocationSelected.onNext(searchedModels.value[idx])
            self.coordinator?.navigationController.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        return output
    }
    
}
