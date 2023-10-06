//
//  ChatVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
import RxSwift

// MARK: - LoginViewModel
class ChatVM {
    weak var coordinator: ChatCoordinator?
    private let disposeBag = DisposeBag()
    private var chatUseCase: ChatUseCase
    private var hundredQAUseCase: HundredQAUseCase
    private var answerArray: [AnswerModel] = []
    private var questionInfo: (String, String) = ("", "")
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let mySendTextMessage: Observable<MockMessage>
        let mySendImageMessage: Observable<MockMessage>
    }
    
    struct Output {
        var senddSuccess = PublishSubject<Bool>()
        var getMessage = PublishSubject<[MockMessage]>()
        var getRealTimeMessage = PublishSubject<[MockMessage]>()
    }
    
    
    struct DisplayInput {
        let viewWillApearEvent: Observable<Void>
        let lastAnswerBtnTapEvent: Observable<Void>
        let goAnswerBtnTapEvent: Observable<Void>
    }
    
    struct DisplayOutput {
        var questionComplete = PublishSubject<String>()
        var questionText = PublishSubject<String>()
        var otherProfileImage = PublishSubject<UIImage>()
    }
    
    // MARK: Input
    init(coordinator: ChatCoordinator,
         chatUseCase: ChatUseCase,
         hundredQAUseCase: HundredQAUseCase) {
        self.coordinator = coordinator
        self.chatUseCase = chatUseCase
        self.hundredQAUseCase = hundredQAUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.chatUseCase.getChatMessageService()
                self.chatUseCase.startRealTimeChatMassage()
            })
            .disposed(by: disposeBag)
        
        
        input.mySendTextMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                self.chatUseCase.sendMessageService(mockMessage: myMessage, chatType: .text)
                    .subscribe(onSuccess: {
                        output.senddSuccess.onNext(true)
                    },onFailure: { error in
                        output.senddSuccess.onNext(false)
                    }).disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.mySendImageMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                self.chatUseCase.sendMessageService(mockMessage: myMessage, chatType: .image)
                    .subscribe(onSuccess: {
                        output.senddSuccess.onNext(true)
                    },onFailure: { error in
                        output.senddSuccess.onNext(false)
                    }).disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        self.chatUseCase.recieveChatMessageService
            .subscribe(onNext: {chatMessageList in
                output.getMessage.onNext(chatMessageList ?? [])
            })
            .disposed(by: disposeBag)
        
        self.chatUseCase.recieveRealTimeMessageService
            .subscribe(onNext: {chatMessageList in
                output.getRealTimeMessage.onNext(chatMessageList ?? [])
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func noticeTransform(input: DisplayInput, disposeBag: DisposeBag) -> DisplayOutput {
        let output = DisplayOutput()

        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.chatUseCase.getProfileImage()
                    .subscribe(onSuccess: { image in
                        output.otherProfileImage.onNext(image)
                    })
                    .disposed(by: disposeBag)
                self.hundredQAUseCase.getAnswerList()
                    .subscribe(onSuccess: {[weak self] model in
                        guard let self = self else{ return }
                        let questionNumber = model.count - 1
                        let answerModel = model.dropLast(1)
                        var answers = answerModel.map{ $0.answerInfo }
                        var question = answerModel.map{ $0.questionText }
                        if answers.filter({ $0.count < 2 }).count == 0 {
                            self.answerArray = answers.popLast() ?? []
                            self.questionInfo.1 = question.popLast() ?? ""
                            self.questionInfo.0 = String(questionNumber)
                            output.questionComplete.onNext("\(String(questionNumber))번째 백문백답을 완료했어요!")
                        }else if answers.filter({ $0.count < 2 }).count == 1 {
                            self.answerArray = answers[1]
                            self.questionInfo.1 = question[1]
                            self.questionInfo.0 = String(questionNumber)
                            output.questionComplete.onNext("\(String(questionNumber))번째 백문백답이 도착했어요!")
                        }else {
                            self.answerArray = answers[0]
                            self.questionInfo.1 = question[0]
                            self.questionInfo.0 = String(questionNumber - 1)
                            output.questionComplete.onNext("\(String(questionNumber - 1))번째 백문백답이 도착했어요!")
                        }
                        
                        output.questionText.onNext(self.questionInfo.1)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.lastAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showHundredQAFlow()
            })
            .disposed(by: disposeBag)
        
        input.goAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                var myAnswerInfo = answerArray.filter{ $0.userId == .mine }.last ?? AnswerModel(userId: .mine, answerText: "", userName: "")
                var otherAnswerInfo = answerArray.filter{ $0.userId == .other }.last ?? AnswerModel(userId: .other, answerText: "", userName: "")
                let myName = UserDefaults.standard.string(forKey: "userName") ?? ""
                let otherName = UserDefaults.standard.string(forKey: "otherUserName") ?? ""
                myAnswerInfo.userName = myName
                otherAnswerInfo.userName = otherName
                self.coordinator?.showReadAnswerVC(questionNumber: String(Int(self.questionInfo.0)!-1),
                                                   question: self.questionInfo.1,
                                                   myAnswerInfo: myAnswerInfo,
                                                   otherAnswerInfo: otherAnswerInfo)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func datesCompare(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
}
    
