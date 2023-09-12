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
        var questionNumber = PublishSubject<String>()
        var questionText = PublishSubject<String>()
        var otherProfileImage = PublishSubject<UIImage>()
    }
    
    // MARK: Input
    init(coordinator: ChatCoordinator, chatUseCase: ChatUseCase) {
        self.coordinator = coordinator
        self.chatUseCase = chatUseCase
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
            })
            .disposed(by: disposeBag)
        
        input.lastAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showHundredQAFlow()
            })
            .disposed(by: disposeBag)
        
        input.goAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                //self?.coordinator?.showWriteAnswerVC(viewModel: <#T##AnswerVM#>, )
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
    
