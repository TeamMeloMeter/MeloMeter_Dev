//
//  MyProfileVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MyProfileVM {

    weak var coordinator: MyProfileCoordinator?
    private var myProfileUseCase: MyProfileUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let editProfileBtnTapEvent: Observable<Void>
        let dDayViewTapEvent: Observable<Void>
        let noticeViewTapEvent: Observable<Void>
    }
    
    struct Output {
        var profileImage = PublishRelay<UIImage?>()
        var userName = PublishRelay<String>()
        var userPhoneNumber = PublishRelay<String>()
        var stateMessage = PublishRelay<String?>()
    }
    
    
    init(coordinator: MyProfileCoordinator, myProfileUseCase: MyProfileUseCase) {
        self.coordinator = coordinator
        self.myProfileUseCase = myProfileUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.myProfileUseCase.getUserInfo()
                    .subscribe(onNext: { user in
                        self.myProfileUseCase.getProfileImage(url: user.profileImage ?? "")
                            .subscribe(onSuccess: { image in
                                output.profileImage.accept(image)
                            })
                            .disposed(by: disposeBag)
                        guard let name = user.name, let phoneNumber = user.phoneNumber else{ return }
                        output.userName.accept(name)
                        var number = phoneNumber.map{ String($0) }
                        number.insert(" 0", at: 3)
                        number.insert("-", at: 6)
                        number.insert("-", at: 11)
                        output.userPhoneNumber.accept(number.joined())
                        output.stateMessage.accept(user.stateMessage)
                        
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.dDayViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showDdayFlow()
            })
            .disposed(by: disposeBag)
        
        input.editProfileBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showEditProfileVC()
            })
            .disposed(by: disposeBag)
        
        input.noticeViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showNoticeVC()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
