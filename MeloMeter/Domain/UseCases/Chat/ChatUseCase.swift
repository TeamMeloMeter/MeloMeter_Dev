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
    private let coupleRepository: CoupleRepository
    private let disposeBag = DisposeBag()
    
    var recieveChatMessageService = PublishRelay<[MockMessage]?>()
    var recieveRealTimeMessageService = PublishRelay<[MockMessage]?>()
    
    // MARK: Initializers
    init(chatRepository: ChatRepository, coupleRepository: CoupleRepository) {
        self.chatRepository = chatRepository
        self.coupleRepository = coupleRepository
    }
    
    // MARK: - Methods
    //메세지 전송 서비스
    func sendMessageService(mockMessage: MockMessage) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                //레파지토리로 넘기기
                self.chatRepository.addChatMessage(mockMessage: mockMessage, coupleID: coupleID)
                    .subscribe(onSuccess: {
                        //데이터베이스 입력성공
                        single(.success(()))
                    },onFailure: { error in
                        //데이터베이스 실패
                        single(.failure(error))
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
            return Disposables.create()
        }
    }
    
    // 메시지 가져오기
    func getChatMessageService() {
        self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.chatRepository.getChatMessage(coupleID: coupleID)
                .compactMap{ DTOArr in
                    let processedDTOArr = DTOArr.map { dto in
                        let processedChatDTO = dto.toModel()
                        return processedChatDTO
                    }
                    return processedDTOArr
                }
                .catchAndReturn(nil)
                .bind(to: self.recieveChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    // 메시지 가져오는 기능 시작
    func startRealTimeChatMassage() {
        self.coupleRepository.getCoupleID()
            .subscribe(onSuccess: { coupleID in
            //실시간 메세지 감시 시작
            self.chatRepository.getRealTimeChat(coupleID: coupleID)
            
            //변경된 값 받아오기
                self.chatRepository.recieveChatMessage.subscribe(onNext: { DTOArr in
                    self.recieveRealTimeMessageService.accept(DTOArr.map({ DTOArr in
                        let processedDTOArr = DTOArr.map { ChatDTO in
                            let processedChatDTO = ChatDTO.toModel()
                            return processedChatDTO
                        }
                        return processedDTOArr
                    })) 
                }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    
}
