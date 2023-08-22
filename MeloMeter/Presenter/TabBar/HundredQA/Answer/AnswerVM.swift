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

enum AnswerBtnType {
    case goAnswer, answerComplete
}

class AnswerVM {

    weak var coordinator: HundredCoordinator?
    private var hundredQAUserCase: HundredQAUserCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let answerBtnTapEvent: Observable<(AnswerBtnType, [String])>
    }
    
    struct Output {
       
    }
    
    init(coordinator: HundredCoordinator, hundredQAUserCase: HundredQAUserCase) {
        self.coordinator = coordinator
        self.hundredQAUserCase = hundredQAUserCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
          
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.answerBtnTapEvent
            .subscribe(onNext: {[weak self] type, text in
                guard let self = self else{ return }
                if type == .goAnswer {
                    self.coordinator?.showWriteAnswerVC(question: text[0], name: text[1])
                }
                if type == .answerComplete {
                    self.hundredQAUserCase.addAnswer(answerText: "1212")
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
}

