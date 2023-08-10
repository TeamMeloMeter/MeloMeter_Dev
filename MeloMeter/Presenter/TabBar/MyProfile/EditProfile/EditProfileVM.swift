//
//  EditProfileVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import UIKit
import RxSwift
import RxRelay

class EditProfileVM {

    weak var coordinator: MyProfileCoordinator?
    private var editProfileUseCase: EditProfileUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var userName = PublishSubject<String>()
        var stateMessage = PublishSubject<String>()
        var birth = PublishSubject<String>()
        var gender = PublishSubject<String>()
    }
    
    
    init(coordinator: MyProfileCoordinator, editProfileUseCase: EditProfileUseCase) {
        self.coordinator = coordinator
        self.editProfileUseCase = editProfileUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.editProfileUseCase.getUserData()
            })
            .disposed(by: disposeBag)
        
        self.editProfileUseCase.userData
            .bind(onNext: { userData in
                print("user:",userData)
                output.userName.onNext(userData.name ?? "이름")
                output.stateMessage.onNext(userData.stateMessage ?? "상태메세지를 변경해보세요!")
                output.birth.onNext(userData.birth?.toString(type: .yearToDay) ?? "")
                
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
