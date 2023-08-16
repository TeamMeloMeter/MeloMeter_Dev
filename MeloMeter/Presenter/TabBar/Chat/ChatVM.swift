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
        let mySendMessage: Observable<MockMessage>
    }
    
    struct Output {
        //전달할 변수
        
    }
    
    // MARK: Input
    // 데이트 타입을 받아서, 우리가 원하는(멜로망스)에 맞는 형태로 바꾸는 메서드를 Date유틸에 추가하고, 이 동작을 하는 메서드를 만들어야해 여기에.
    init(coordinator: ChatCoordinator, chatUseCase: ChatUseCase) {
        self.coordinator = coordinator
        self.chatUseCase = chatUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.mySendMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                
                print("@@@@@@@@@@@@@@@@@@")
                print("VM")
                print(myMessage)
                print("@@@@@@@@@@@@@@@@@@")
                
                self.chatUseCase.sendNumberService(mockMessage: myMessage)
                    .subscribe(onSuccess: {
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
    
