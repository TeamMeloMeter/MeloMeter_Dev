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
        //전달받을 변수
        let viewDidLoadEvent: Observable<Void>
        let viewWillApearEvent: Observable<Void>
        let mySendMessage: Observable<MockMessage>
    }
    
    struct Output {
        //전달할 변수
        var senddSuccess = PublishSubject<Bool>()
        var getMessage = PublishSubject<[MockMessage]>()
        var getRealTimeMessage = PublishSubject<[MockMessage]>()
    }
    
    // MARK: Input
    // 데이트 타입을 받아서, 우리가 원하는(멜로망스)에 맞는 형태로 바꾸는 메서드를 Date유틸에 추가하고, 이 동작을 하는 메서드를 만들어야해 여기에.
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
        
//        input.viewWillApearEvent
//            .subscribe(onNext: { [weak self] _ in
//                guard let self = self else{ return }
//
//            })
//            .disposed(by: disposeBag)
        
        input.mySendMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                self.chatUseCase.sendMessageService(mockMessage: myMessage)
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
        
        return output
    }
    
}
    
