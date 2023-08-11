//
//  DetailEditVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import UIKit
import RxSwift
import RxRelay

class DetailEditVM {

    weak var coordinator: MyProfileCoordinator?
    private var editProfileUseCase: EditProfileUseCase
    var name = ""
    var stateMessage = ""
    var birth = ""
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let changedName: Observable<String>?
        let changedStateMessage: Observable<String>?
        let changedBirth: Observable<String>?
    }
    
    struct Output {
        var inputError = PublishSubject<Bool>()
    }
    
    
    init(coordinator: MyProfileCoordinator, editProfileUseCase: EditProfileUseCase) {
        self.coordinator = coordinator
        self.editProfileUseCase = editProfileUseCase
    }
    
    func nameTransform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.changedName?
            .subscribe(onNext: { name in
                if name.isEmpty {
                    output.inputError.onNext(true)
                }else {
                    output.inputError.onNext(false)
                    self.editProfileUseCase.editInfo(field: .name, value: name)
                        .subscribe(onSuccess: {
                            self.coordinator?.popViewController()
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
