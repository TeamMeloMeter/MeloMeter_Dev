//
//  AnswerVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class AnswerVM {

    weak var coordinator: HundredCoordinator?
    private var hundredQAUseCase: HundredQAUseCase
    var questionNumber: String
    var questionText: String
    var myAnswerInfo: AnswerModel
    var otherAnswerInfo: AnswerModel
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let answerBtnTapEvent: Observable<Void>?
        let answerInputText: Observable<String>?
    }
    
    
    struct Output {
        var questionNumber = PublishSubject<String>()
        var questionText = PublishSubject<String>()
        var myAnswerInfo = PublishSubject<AnswerModel>()
        var otherAnswerInfo = PublishSubject<AnswerModel>()
        var isAnswers = PublishSubject<[Bool]>()
    }
    
    struct WriteOutput {
        var questionText = PublishSubject<String>()
        var myName = PublishSubject<String>()
    }
    
    init(coordinator: HundredCoordinator,
         hundredQAUseCase: HundredQAUseCase,
         questionNumber: String,
         questionText: String,
         myAnswerInfo: AnswerModel,
         otherAnswerInfo: AnswerModel
    ) {
        self.coordinator = coordinator
        self.hundredQAUseCase = hundredQAUseCase
        self.questionNumber = questionNumber
        self.questionText = questionText
        self.myAnswerInfo = myAnswerInfo
        self.otherAnswerInfo = otherAnswerInfo
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                output.questionNumber.onNext(self.questionNumber)
                output.questionText.onNext(self.questionText)
                var isAnswers = [false, false]
                if !self.myAnswerInfo.answerText.isEmpty {
                    isAnswers[0] = true
                }
                if !self.otherAnswerInfo.answerText.isEmpty {
                    isAnswers[1] = true
                }
                output.myAnswerInfo.onNext(self.myAnswerInfo)
                output.otherAnswerInfo.onNext(self.otherAnswerInfo)
                output.isAnswers.onNext(isAnswers)
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.answerBtnTapEvent?
            .subscribe(onNext: {[weak self] type in
                guard let self = self else{ return }
                self.coordinator?.showWriteAnswerVC(viewModel: self)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func writeTransform(input: Input, disposeBag: DisposeBag) -> WriteOutput {
        let output = WriteOutput()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                
                output.myName.onNext(self.myAnswerInfo.userName)
                output.questionText.onNext(self.questionText)
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.answerInputText?
            .subscribe(onNext: {[weak self] text in
                guard let self = self else{ return }
                let answerInfo = AnswerModel(
                    userId: .mine,
                    answerText: text,
                    userName: self.myAnswerInfo.userName
                )
                self.hundredQAUseCase.addAnswer(questionNumber: self.questionNumber, answerInfo: answerInfo)
                    .subscribe(onSuccess: {
                        self.coordinator?.popViewController()
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
}

