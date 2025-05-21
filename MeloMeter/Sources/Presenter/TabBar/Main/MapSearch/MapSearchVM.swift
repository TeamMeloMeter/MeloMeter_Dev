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
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchText: Observable<String>
        let keyBoardBtnTapped: Observable<Void>
        let tapIdx: Observable<Int>
        let backBtnTapped: Observable<UITapGestureRecognizer>
    }
    
    struct Output {
        let resultModels = BehaviorSubject<[SearchedModel]>(value: [])
        
        //TODO: 이후에 탭 시 push 할지 pop 해서 처리할지 로직 개선 해야함.
        let testingPickMarker = BehaviorSubject<SearchedModel?>(value: nil)
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
        
        input.keyBoardBtnTapped.withLatestFrom(input.searchText).subscribe(onNext: { [weak self] text in
            guard let self else {return}
            searchUseCase.getResults(text: text).subscribe(onSuccess:{ [weak self] in
                guard let self else {return}
                searchedModels.accept($0)
                output.resultModels.onNext($0)
            }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        input.tapIdx.subscribe(onNext: { [weak self] idx in
            guard let self else {return}
            let pickedValue = searchedModels.value[idx]
            output.testingPickMarker.onNext(pickedValue)
            // TODO: 화면전환 어떻게 할지 개선
            coordinator?.showMapVC(pickedModel: pickedValue)
        }).disposed(by: disposeBag)
        
        return output
    }
    
}
