//
//  HundredQAVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class HundredQAVM {

    weak var coordinator: HundredCoordinator?
    private var hundredQAUseCase: HundredQAUseCase
    var answerArray: [[AnswerModel]] = []
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let cellTapEvent: Observable<(Int, String)>
    }
    
    struct Output {
        var questionBottomData = PublishSubject<[String]>()
        var questionTopData = PublishSubject<[String]>()
        var questionNumbers = PublishSubject<[[String]]>()
    }
    
    init(coordinator: HundredCoordinator, hundredQAUseCase: HundredQAUseCase) {
        self.coordinator = coordinator
        self.hundredQAUseCase = hundredQAUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.hundredQAUseCase.getAnswerList()
                    .subscribe(onSuccess: { answerModel in
                        self.answerArray = answerModel.map{ $0.answerInfo }
                        let questionTextArray = answerModel.map{ $0.questionText }
                        var topData: [String] = []
                        var bottomData: [String] = []
                        var numbers: [[String]] = Array(repeating: [], count: 2)
                        for answers in 0..<self.answerArray.count {
                            if self.answerArray[answers].count < 2 {
                                topData.append(questionTextArray[answers])
                                numbers[0].append(String(answers + 1))
                            }else {
                                bottomData.append(questionTextArray[answers])
                                numbers[1].append(String(answers + 1))
                            }
                        }
                        output.questionNumbers.onNext(numbers)
                        output.questionTopData.onNext(topData)
                        output.questionBottomData.onNext(bottomData)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        input.cellTapEvent
            .subscribe(onNext: {[weak self] (index, question) in
                guard let self = self else{ return }
                var myAnswerInfo = answerArray[index].filter{ $0.userId == .mine }.last ?? AnswerModel(userId: .mine, answerText: "", userName: "")
                var otherAnswerInfo = answerArray[index].filter{ $0.userId == .other }.last ?? AnswerModel(userId: .other, answerText: "", userName: "")
                let myName = UserDefaults.standard.string(forKey: "userName") ?? ""
                let otherName = UserDefaults.standard.string(forKey: "otherUserName") ?? ""
                myAnswerInfo.userName = myName
                otherAnswerInfo.userName = otherName
                self.coordinator?.showReadAnswerVC(questionNumber: String(index),
                                                   question: question,
                                                   myAnswerInfo: myAnswerInfo,
                                                   otherAnswerInfo: otherAnswerInfo)
            })
            .disposed(by: disposeBag)

        return output
    }
    
}

