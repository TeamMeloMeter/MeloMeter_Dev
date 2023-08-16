//
//  ChatUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import UIKit
import Firebase
import RxSwift
import RxRelay

enum ChatServiceError: Error {
    case sendMessageFailure
}

class ChatUseCase {
    
    // MARK: - Property
    private let chatRepository: ChatRepository
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    // MARK: - Methods
    //메세지 전송 서비스
    func sendNumberService(mockMessage: MockMessage) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            //레파지토리로 넘기기
            self.chatRepository.addChatMessage(mockMessage: mockMessage)
                .subscribe(onSuccess: {
                    //데이터베이스 입력성공
                    single(.success(()))
                },onFailure: { error in
                    //데이터베이스 실패
                    single(.failure(error))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
}
