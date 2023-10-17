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
    
    var recieveChatMessage = PublishSubject<[ChatDTO]?>()
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    // ChatModel타입을 인자로 받아서 fireBase에 insert하는 함수 / 리턴 t/f
    func addChatMessage(message: ChatModel, coupleID: String) -> Single<Void> {
        let dto = message.toDTO()
        let values = dto.asDictionary ?? [:]
        let userName = UserDefaults.standard.string(forKey: "userName") ?? "상대방"
        //푸시노티
        PushNotificationService.shared.sendPushNotification(title: userName, body: values["contents"] as? String ?? "메세지가 도착했어요!", type: AlarmType.defaultValue)
        
        return self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : FieldValue.arrayUnion([values]) ])
    }
    
    // 이미지 메세지 처리
    func addImageMessage(chatModel: ChatModel, coupleID: String) -> Single<Void> {
        switch chatModel.kind {
        case .photo(let photo):
            guard let image = photo.image else{ return Single.error(FireStoreError.unknown)}
            let uuidData = UUID().uuidString
            return self.firebaseService.uploadImage(filePath: "chat/"+coupleID+"/"+uuidData, image: image)
                .flatMap{ url in
                    let dto = chatModel.toDTO(url: url)
                    let values = dto.asDictionary ?? [:]
                    let userName = UserDefaults.standard.string(forKey: "userName") ?? "상대방"
                    //푸시노티
                    PushNotificationService.shared.sendPushNotification(title: userName, body: "(사진)", type: AlarmType.defaultValue)
                    
                    return self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : FieldValue.arrayUnion([values]) ])
                }
        default:
            return Single.error(FireStoreError.unknown)
        }
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
                    
                    //300개 넘어가면 오래된 순으로 삭제
                    if sortedChatFields.count > 300{
                        let values = Array(sortedChatFields[1..<sortedChatFields.count])
                        self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : values] )
                            .subscribe(onSuccess: {})
                            .disposed(by: self.disposeBag)
                    }
                    else {
                        let numberOfMessagesToRetrieve = 1
                        let recentChatFields = Array(sortedChatFields.suffix(numberOfMessagesToRetrieve))
                        self.recieveChatMessage.onNext(self.convertToChatDTOArray(from: recentChatFields))
                    }
                } else {
                    self.recieveChatMessage.onNext([])
                }
            }) { error in
                self.recieveChatMessage.onNext(nil)
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
    
    //추가 30개 가져오기
    func getMoreChatMessage(num: Int, coupleID: String) -> Observable<[ChatDTO]> {
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
                    
                    var myChatCount = num
                    //내화면에 채팅개수가 데이터 베이스를 초과하지 않게 만듬
                    if sortedChatFields.count < myChatCount {
                        myChatCount = sortedChatFields.count
                    }
                    // 최대 20개의 매세지를 가져온다
                    let numberOfMessagesToRetrieve = min(sortedChatFields.count - 20, 20)
                    // 추가로 가져올 데이터가 없다면 리턴
                    if numberOfMessagesToRetrieve < 0 { return [] }
                    let end = sortedChatFields.count - myChatCount // 0 일수도있음
                    var start = end - 20
                    if start < 0 { start = 0 }
                    let recentChatFields = sortedChatFields[start ..< end]
                    
                    // DTO타입으로 형변환
                    return self.convertToChatDTOArray(from: Array(recentChatFields))
                } else {
                    return []
                }
            }
            .asObservable()
    }
    
    func downloadImage(url: String) -> Single<UIImage?> {
        return self.firebaseService.downloadImage(urlString: url)
    }
    
    //딕셔너리로 가져온 데이터 [DTO] 로 변환
    func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO] {
        var chatDTOArray: [ChatDTO] = []
        
        for dictionary in dictionaries {
            if let contents = dictionary["contents"] as? String,
               let chatType = dictionary["chatType"] as? String,
               let userId = dictionary["userId"] as? String,
               let messageId = dictionary["messageId"] as? String,
               let date = dictionary["date"] as? [String:Int]
            {
                let timestamp = Timestamp(seconds: Int64(date["seconds"] ?? 0), nanoseconds: Int32(date["nanoseconds"] ?? 0))
                
                let chatDTO = ChatDTO(chatType: chatType, contents: contents, userId: userId, messageId: messageId, date: timestamp)
                chatDTOArray.append(chatDTO)
            }
        }
        return chatDTOArray
    }
    
    func getChatImagesURL(coupleID: String) -> Single<[String]> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .map { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]], !chatFields.isEmpty{
                    let chatArray = self.convertToChatDTOArray(from: chatFields)
                    return chatArray.filter({ $0.chatType == ChatType.image.stringType }).compactMap({ $0.contents })
                } else {
                    return []
                }
            }
            
    }
        
}

