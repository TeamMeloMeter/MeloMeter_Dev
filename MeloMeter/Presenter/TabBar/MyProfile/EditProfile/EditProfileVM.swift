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
        let changedProfileImage: Observable<UIImage>
        let nameTapEvent: Observable<Void>
        let stateMessageTapEvent: Observable<Void>
        let birthTapEvent: Observable<Void>
        let newGender: Observable<GenderType>

    }

    struct Output {
        var profileImage = PublishSubject<UIImage?>()
        var uploadSuccess = PublishSubject<Bool>()
        var userName = PublishSubject<String>()
        var stateMessage = PublishSubject<String>()
        var birth = PublishSubject<String>()
        var gender = PublishSubject<String>()
    }
    
    struct DetailData {
        var userName = ""
        var stateMessage = ""
        var birth = ""
    }
    
    init(coordinator: MyProfileCoordinator, editProfileUseCase: EditProfileUseCase) {
        self.coordinator = coordinator
        self.editProfileUseCase = editProfileUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        var detailData = DetailData()
        
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.editProfileUseCase.getUserData()
            })
            .disposed(by: disposeBag)
        
        self.editProfileUseCase.userData
            .bind(onNext: { userData in
                self.editProfileUseCase.getProfileImage(url: userData.profileImage ?? "")
                    .asObservable()
                    .take(1)
                    .bind(to: output.profileImage)
                    .disposed(by: disposeBag)
                detailData.userName = userData.name ?? ""
                detailData.stateMessage = userData.stateMessage ?? ""
                detailData.birth = userData.birth?.toString(type: .yearToDay) ?? ""
                output.userName.onNext(userData.name ?? "이름")
                output.stateMessage.onNext(userData.stateMessage ?? "상태메세지를 변경해보세요!")
                output.birth.onNext(userData.birth?.toString(type: .yearToDay) ?? "")
                output.gender.onNext(userData.gender?.stringType ?? "남")
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.changedProfileImage
            .subscribe(onNext: {[weak self] image in
                guard let self = self else{ return }
                self.editProfileUseCase.editProfileImage(image: image)
                .subscribe(onSuccess: {
                    output.uploadSuccess.onNext(true)
                }, onFailure: { error in
                    output.uploadSuccess.onNext(false)
                })
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.nameTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showEditNameVC(name: detailData.userName)
            })
            .disposed(by: disposeBag)
        
        input.stateMessageTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showEditStateMessageVC(
                    stateMessage: detailData.stateMessage == "상태메세지를 변경해보세요!" ? "" : detailData.stateMessage
                )
            })
            .disposed(by: disposeBag)
        
        input.birthTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showEditBirthVC(birth: detailData.birth)
            })
            .disposed(by: disposeBag)
        
        input.newGender
            .subscribe(onNext: {[weak self] genderType in
                self?.editProfileUseCase.editInfo(field: .gender, value: genderType.stringType)
                    .subscribe(onSuccess: {
                        output.gender.onNext(genderType.stringType)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
