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
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()

    var recieveChatMessageService = PublishRelay<[MockMessage]?>()
    var recieveRealTimeMessageService = PublishRelay<[MockMessage]?>()
    
    // MARK: Initializers
    init(chatRepository: ChatRepository,
         coupleRepository: CoupleRepository,
         userRepository: UserRepository)
    {
        self.chatRepository = chatRepository
        self.coupleRepository = coupleRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Methods
    //메세지 전송 서비스
    func sendMessageService(mockMessage: MockMessage, chatType: ChatType) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.coupleRepository.getCoupleID().subscribe(onSuccess: { coupleID in
                switch chatType{
                case .text:
                    //레파지토리로 넘기기
                    self.chatRepository.addChatMessage(message: mockMessage, coupleID: coupleID)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        },onFailure: { error in
                            //데이터베이스 실패
                            single(.failure(error))
                        }).disposed(by: self.disposeBag)
                case .image:
                    //레파지토리로 넘기기
                    self.chatRepository.addImageMessage(mockMessage: mockMessage, coupleID: coupleID)
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
                .flatMap { DTOArr -> Single<[MockMessage]> in
                    return self.downloadChatImages(DTOArray: DTOArr)
                }
                .bind(to: self.recieveChatMessageService)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func downloadChatImages(DTOArray: [ChatDTO]) -> Single<[MockMessage]> {
        return Single.create{ single in
            var resultMockMessageArray: [MockMessage] = []
            let textTypeArray = DTOArray.filter{ $0.chatType == "text" }.map{ $0.toModel() }
            resultMockMessageArray = textTypeArray
            let imageTypeArray = DTOArray.filter{ $0.chatType == "image" }
            if imageTypeArray.isEmpty {
                single(.success(resultMockMessageArray))
            }
            for dto in imageTypeArray {
                self.chatRepository.downloadImage(url: dto.contents ?? "")
                    .subscribe(onSuccess: { getimage in
                        guard let getimage = getimage else{ return }
                        let imageMessageModel = dto.toModel(image: getimage)
                        resultMockMessageArray.append(imageMessageModel)
                        if resultMockMessageArray.count == DTOArray.count {
                            let result = resultMockMessageArray.sorted(by: { $0.sentDate < $1.sentDate })
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
            .subscribe(onSuccess: { coupleID in
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
                        }else {
                            return UIImage(named: "defaultProfileImage")!
                        }
                    }
            }
    }
    
}
