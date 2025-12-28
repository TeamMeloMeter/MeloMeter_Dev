//
//  DetailEditVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import UIKit
import RxSwift
import RxRelay
import Domain
import Core

public enum CameraAlert {
    case take, get, delete, cancel
}

public class DetailEditVM {

    weak var coordinator: MyProfileCoordinator?
    private var editProfileUseCase: EditProfileUseCase
    public var name = ""
    public var stateMessage = ""
    public var birth = ""
    
    public struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let changedName: Observable<String>?
        let changedStateMessage: Observable<String>?
        let changedBirth: Observable<String>?
    }
    
    public struct Output {
        var inputError = PublishSubject<Bool>()
    }
    
    
    public init(coordinator: MyProfileCoordinator, editProfileUseCase: EditProfileUseCase) {
        self.coordinator = coordinator
        self.editProfileUseCase = editProfileUseCase
    }
    
    // MARK: EditName
    public func nameTransform(input: Input, disposeBag: DisposeBag) -> Output {
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
    
    // MARK: EditStateMessage
    public func stateMessageTransform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.changedStateMessage?
            .subscribe(onNext: { stateMessage in
                if stateMessage.isEmpty {
                    output.inputError.onNext(true)
                }else {
                    output.inputError.onNext(false)
                    self.editProfileUseCase.editInfo(field: .stateMessage, value: stateMessage)
                        .subscribe(onSuccess: {
                            self.coordinator?.popViewController()
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    // MARK: EditBirth
    public func birthTransform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.changedBirth?
            .subscribe(onNext: { birth in
                if birth.isEmpty {
                    output.inputError.onNext(true)
                }else {
                    output.inputError.onNext(false)
                    self.editProfileUseCase.editInfo(field: .birth, value: birth)
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
