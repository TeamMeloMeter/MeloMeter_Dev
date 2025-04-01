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
    private let chatRepository: ChatRepositoryP
    private let coupleRepository: CoupleRepositoryP
    private let userRepository: UserRepositoryP
    private let disposeBag = DisposeBag()

    var recieveChatMessageService = PublishRelay<[ChatModel]?>()
    var recieveMoreChatMessageService = PublishRelay<[ChatModel]?>()
    var recieveRealTimeMessageService = PublishRelay<[ChatModel]?>()
    var recieveMessageId = PublishRelay<String>()
    
    //by seungwan
    var recieveChatForSearch = PublishRelay<[ChatModel]?>()
    
    // MARK: Initializers
    init(chatRepository: ChatRepositoryP,
         coupleRepository: CoupleRepositoryP,
         userRepository: UserRepositoryP)
    {
        self.chatRepository = chatRepository
        self.coupleRepository = coupleRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Methods
    //메세지 전송 서비스
    func sendMessageService(chatModel: ChatModel, chatType: ChatType) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                switch chatType{
                case .text:
                    //레파지토리로 넘기기
                    self.chatRepository.addChatMessage(message: chatModel, coupleID: coupleID)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        },onFailure: { error in
                            //데이터베이스 실패
                            single(.failure(error))
                        }).disposed(by: self.disposeBag)
                case .image:
                    //레파지토리로 넘기기
                    self.chatRepository.addImageMessage(chatModel: chatModel, coupleID: coupleID)
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
    func getChatMessageService() {
        self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.chatRepository.getChatMessage(coupleID: coupleID)
                .flatMap { DTOArr -> Single<[ChatModel]> in
                    return self.downloadChatImages(DTOArray: DTOArr)
                }
                .bind(to: self.recieveChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    // 추가메시지 가져오기
    func getMoreChatMessageService(num: Int) {
        self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.chatRepository.getMoreChatMessage(num : num, coupleID: coupleID, searchText: nil)
                .flatMap { DTOArr -> Single<[ChatModel]> in
                    return self.downloadChatImages(DTOArray: DTOArr)
                }
                .bind(to: self.recieveMoreChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    // by seungwan
    //MARK: 추가메시지 가져오기 for search
    ////TODO: 추가메시지 보낸 후 바로 VC로 전송하지 말고 먼저 평가 후 있다면 VC로 전송.(V2)
    func getMoreChatForSearch(num: Int, searchText: String?) {
        if let searchText = searchText, !searchText.isEmpty {
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                
                self.chatRepository.getMessageSearch(coupleID: coupleID, searchGText: searchText, num: num)
                    .flatMap { DTOArr, messageId -> Single<[ChatModel]> in
                      
                        self.recieveMessageId.accept(messageId)
                        return self.downloadChatImages(DTOArray: DTOArr)
                    }
                    .bind(to: self.recieveChatForSearch)
                    .disposed(by: self.disposeBag)
                
                
            }).disposed(by: disposeBag)
        }
    
    }
    
    
    
    func downloadChatImages(DTOArray: [ChatDTO]) -> Single<[ChatModel]> {
        return Single.create{ single in
            var resultChatModelArray: [ChatModel] = []
            let textTypeArray = DTOArray.filter{ $0.chatType == "text" }.map{ $0.toModel() }
            resultChatModelArray = textTypeArray
            let imageTypeArray = DTOArray.filter{ $0.chatType == "image" }
            if imageTypeArray.isEmpty {
                single(.success(resultChatModelArray))
            }
            for dto in imageTypeArray {
                self.chatRepository.downloadImage(url: dto.contents ?? "")
                    .subscribe(onSuccess: { getimage in
                        guard let getimage = getimage else{ return }
                        let imageMessageModel = dto.toModel(image: getimage)
                        resultChatModelArray.append(imageMessageModel)
                        if resultChatModelArray.count == DTOArray.count {
                            let result = resultChatModelArray.sorted(by: { $0.sentDate < $1.sentDate })
                            single(.success(result))
                            return
                        }
                    }, onFailure: { error in
                        single(.failure(error))
                        return
                    })
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
    // 메시지 가져오는 기능 시작
    func startRealTimeChatMassage() {
        self.coupleRepository.getCoupleID()
            .subscribe(onSuccess: { [weak self] coupleID in
                guard let self else {return}
                //실시간 메세지 감시 시작
                self.chatRepository.getRealTimeChat(coupleID: coupleID)
                //변경된 값 받아오기
                self.chatRepository.recieveChatMessage.subscribe(onNext: { DTOArr in
                    guard let dtoArray = DTOArr else{ return }
                    self.downloadChatImages(DTOArray: dtoArray)
                        .subscribe(onSuccess: { messageArray in
                            self.recieveRealTimeMessageService.accept(messageArray)
                        })
                        .disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    func getProfileImage() -> Single<UIImage> {
        guard let uid = UserDefaults.standard.string(forKey: "otherUid") else{ return Single.just(UIImage(named: "defaultProfileImage")!)}
            return userRepository.getUserInfo(uid)
            .asSingle()
            .flatMap{ userInfo -> Single<UIImage> in
                return self.chatRepository.downloadImage(url: userInfo.profileImage ?? "")
                    .map{ image in
                        if let image = image {
                            return image
                        } else {
                            return UIImage(named: "defaultProfileImage")!
                        }
                    }
            }
    }
    
}
