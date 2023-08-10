//
//  PermissionVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/26.
//

import UIKit
import RxSwift

class PermissionVM {

    weak var coordinator: PresetCoordinator?
    private let disposeBag = DisposeBag()
    private var mainUseCase: MainUseCase
    
    struct Input1 {
        let startBtnTapped1: Observable<Void>
    }
    
    struct Input2 {
        let viewDidApearEvent: Observable<Void>
        let startBtnTapped2: Observable<Void>
    }

    init(coordinator: PresetCoordinator, mainUseCase: MainUseCase) {
        
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        
    }
    
    func transform1(input: Input1, disposeBag: DisposeBag) {
        input.startBtnTapped1
            .subscribe(onNext: {
                self.coordinator?.showPermissionVC2()
            })
            .disposed(by: disposeBag)
    }
    
    func transform2(input: Input2, disposeBag: DisposeBag) {
        
        input.viewDidApearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.mainUseCase.requestAuthorization()
            })
            .disposed(by: disposeBag)
        
        input.startBtnTapped2
            .subscribe(onNext: {
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
    
    }
}
