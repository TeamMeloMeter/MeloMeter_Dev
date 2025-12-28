//
//  ChatUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import RxSwift
import RxRelay

public enum ChatServiceError: Error {
    case sendMessageFailure
}

public class ChatUseCase {
    
    // MARK: - Property
    private let chatRepository: ChatRepositoryP
    private let coupleRepository: CoupleRepositoryP
    private let userRepository: UserRepositoryP
    private let disposeBag = DisposeBag()

    public var recieveChatMessageService = PublishRelay<[ChatMessage]?>()
    public var recieveMoreChatMessageService = PublishRelay<[ChatMessage]?>()
    public var recieveRealTimeMessageService = PublishRelay<[ChatMessage]?>()
    public var recieveMessageId = PublishRelay<String>()
    
    //by seungwan
    public var recieveChatForSearch = PublishRelay<[ChatMessage]?>()
    
    // MARK: Initializers
    public init(chatRepository: ChatRepositoryP,
         coupleRepository: CoupleRepositoryP,
         userRepository: UserRepositoryP)
    {
        self.chatRepository = chatRepository
        self.coupleRepository = coupleRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Methods
    //메세지 전송 서비스
    public func sendMessageService(chatMessage: ChatMessage, chatType: ChatType) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                switch chatType{
                case .text:
                    self.chatRepository.addChatMessage(message: chatMessage, coupleID: coupleID)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        },onFailure: { error in
                            //데이터베이스 실패
                            single(.failure(error))
                        }).disposed(by: self.disposeBag)
                case .image:
                    //레파지토리로 넘기기
                    self.chatRepository.addImageMessage(chatMessage: chatMessage, coupleID: coupleID)
                        .subscribe(onSuccess: {
                            //데이터베이스 입력성공
                            single(.success(()))
                        },onFailure: { error in
                            //데이터베이스 실패
                            single(.failure(error))
                        }).disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
        
            return Disposables.create()
        }
    }
    
    // 메시지 가져오기
    public func getChatMessageService() {
        self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.chatRepository.getChatMessage(coupleID: coupleID)
                .bind(to: self.recieveChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    // 추가메시지 가져오기
    public func getMoreChatMessageService(num: Int) {
        self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.chatRepository.getMoreChatMessage(num : num, coupleID: coupleID, searchText: nil)
                .bind(to: self.recieveMoreChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    // by seungwan
    //MARK: 추가메시지 가져오기 for search
    ////TODO: 추가메시지 보낸 후 바로 VC로 전송하지 말고 먼저 평가 후 있다면 VC로 전송.(V2)
    public func getMoreChatForSearch(num: Int, searchText: String?) {
        if let searchText = searchText, !searchText.isEmpty {
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                
                self.chatRepository.getMessageSearch(coupleID: coupleID, searchGText: searchText, num: num)
                    .subscribe(onNext: { [weak self] messageArray, messageId in
                        self?.recieveMessageId.accept(messageId)
                        self?.recieveChatForSearch.accept(messageArray)
                    })
                    .disposed(by: self.disposeBag)
                
                
            }).disposed(by: disposeBag)
        }
    
    }
    // 메시지 가져오는 기능 시작
    public func startRealTimeChatMessage() {
        self.coupleRepository.getCoupleID()
            .subscribe(onSuccess: { [weak self] coupleID in
                guard let self else {return}
                //실시간 메세지 감시 시작
                self.chatRepository.getRealTimeChat(coupleID: coupleID)
                //변경된 값 받아오기
                self.chatRepository.recieveChatMessage
                    .subscribe(onNext: { [weak self] messageArray in
                        guard let messageArray else { return }
                        self?.recieveRealTimeMessageService.accept(messageArray)
                    })
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    public func getProfileImage() -> Single<Data?> {
        guard let uid = UserDefaults.standard.string(forKey: "otherUid") else {
            return Single.just(nil)
        }
        return userRepository.getUserInfo(uid)
            .asSingle()
            .flatMap { userInfo in
                return self.userRepository.downloadImage(url: userInfo.profileImage ?? "")
            }
    }
    
}
