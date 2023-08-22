//
//  ChatRepository.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

enum ChatMessageError: Error {
    case emptyDocument
}

class ChatRepository: ChatRepositoryP{
    
    var recieveChatMessage = PublishRelay<[ChatDTO]?>()
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    // MockMessage타입을 인자로 받아서 fireBase에 insert하는 함수 / 리턴 t/f
    func addChatMessage(mockMessage: MockMessage, coupleID: String) -> Single<Void> {
        let dto = mockMessage.toDTO()
        let values = dto.asDictionary ?? [:]
        return self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : FieldValue.arrayUnion([values]) ])
        
    }
    
    //실시간으로 변경되는 문서 가져오기
    func getRealTimeChat(coupleID: String) {
        self.firebaseService.observer(collection: .Chat, document: coupleID)
            .subscribe(onNext: { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]],  !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = dict1["date"] as? Timestamp,
                              let date2 = dict2["date"] as? Timestamp else {
                            return false
                        }
                        return date1.seconds > date2.seconds ||
                        (date1.seconds == date2.seconds && date1.nanoseconds > date2.nanoseconds)
                    }
                    // 최대 30개의 매세지를 가져온다
                    let numberOfMessagesToRetrieve = 1
                    let recentChatFields = Array(sortedChatFields.suffix(numberOfMessagesToRetrieve))
                    
                    // DTO타입으로 형변환
                    self.recieveChatMessage.accept(self.convertToChatDTOArray(from: recentChatFields))
                } else {
                    //비어있는경우
                    self.recieveChatMessage.accept([])
                }
            }) { error in
                self.recieveChatMessage.accept(nil)
            }
            .disposed(by: disposeBag)
    }
    
    //최근 30개 가져오기
    func getChatMessage(coupleID: String) -> Observable<[ChatDTO]> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .compactMap { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]],  !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = dict1["date"] as? Timestamp,
                              let date2 = dict2["date"] as? Timestamp else {
                            return false
                        }
                        return date1.seconds > date2.seconds ||
                        (date1.seconds == date2.seconds && date1.nanoseconds > date2.nanoseconds)
                    }
                    // 최대 30개의 매세지를 가져온다
                    let numberOfMessagesToRetrieve = min(sortedChatFields.count, 30)
                    let recentChatFields = Array(sortedChatFields.suffix(numberOfMessagesToRetrieve))
                    
                    // DTO타입으로 형변환
                    return self.convertToChatDTOArray(from: recentChatFields)
                } else {
                    return []
                }
            }
            .asObservable()
    }
    
    //딕셔너리로 가져온 데이터 [DTO] 로 변환
    func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO] {
        var chatDTOArray: [ChatDTO] = []
        
        for dictionary in dictionaries {
            if let text = dictionary["text"] as? String,
               let userId = dictionary["userId"] as? String,
               let messageId = dictionary["messageId"] as? String,
               let date = dictionary["date"] as? [String:Int]
            {
                let timestamp = Timestamp(seconds: Int64(date["seconds"] ?? 0), nanoseconds: Int32(date["nanoseconds"] ?? 0))
                
                let chatDTO = ChatDTO(text: text, userId: userId, messageId: messageId, date: timestamp)
                chatDTOArray.append(chatDTO)
            }
        }
        return chatDTOArray
    }
    
}

