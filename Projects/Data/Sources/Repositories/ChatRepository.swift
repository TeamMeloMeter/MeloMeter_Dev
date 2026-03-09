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
#if canImport(Domain)
import Domain
#endif

public enum ChatMessageError: Error {
    case emptyDocument
}

public class ChatRepository: ChatRepositoryP {
    
    public var lastSearchedMessageID: String?
    public var recieveChatMessage = PublishSubject<[ChatMessage]?>()
    public var firebaseService: FirebaseService
    public var disposeBag: DisposeBag
    
    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    // ChatMessage를 인자로 받아서 fireBase에 insert하는 함수
    public func addChatMessage(message: ChatMessage, coupleID: String) -> Single<Void> {
        guard case .text = message.content else {
            return Single.error(FireStoreError.unknown)
        }
        let dto = message.toDTO()
        let values = chatValues(from: dto)
        // 왜 dic 으로 바꾸는거..
        let userName = UserDefaults.standard.string(forKey: "name") ?? "상대방"
        //푸시노티
        PushNotificationService.shared.sendPushNotification(title: userName, body: values["contents"] as? String ?? "메세지가 도착했어요!", type: AlarmType.defaultValue)
        
        return self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : FieldValue.arrayUnion([values]) ])
    }
    
    // 이미지 메세지 처리
    public func addImageMessage(chatMessage: ChatMessage, coupleID: String) -> Single<Void> {
        switch chatMessage.content {
        case .imageData(let imageData):
            let uuidData = UUID().uuidString
            return self.firebaseService.uploadImage(filePath: "chat/"+coupleID+"/"+uuidData, data: imageData)
                .flatMap{ url in
                    let dto = chatMessage.toDTO(url: url)
                    let values = self.chatValues(from: dto)
                    let userName = UserDefaults.standard.string(forKey: "name") ?? "상대방"
                    //푸시노티
                    PushNotificationService.shared.sendPushNotification(title: userName, body: "(사진)", type: AlarmType.defaultValue)
                    
                    return self.firebaseService.updateDocument(collection: .Chat, document: coupleID, values: ["chatField" : FieldValue.arrayUnion([values]) ])
                }
        default:
            return Single.error(FireStoreError.unknown)
        }
    }

    
    //실시간으로 변경되는 문서 가져오기
    public func getRealTimeChat(coupleID: String) {
        self.firebaseService.observer(collection: .Chat, document: coupleID)
            .subscribe(onNext: { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]],  !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = self.dateFromFirestoreValue(dict1["date"]),
                              let date2 = self.dateFromFirestoreValue(dict2["date"]) else {
                            return false
                        }
                        return date1 > date2
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
                        self.recieveChatMessage.onNext(self.convertToChatMessageArray(from: recentChatFields))
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
    public func getChatMessage(coupleID: String) -> Observable<[ChatMessage]> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .compactMap { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]],  !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = self.dateFromFirestoreValue(dict1["date"]),
                              let date2 = self.dateFromFirestoreValue(dict2["date"]) else {
                            return false
                        }
                        return date1 > date2
                    }
                    // 최대 30개의 매세지를 가져온다
                    let numberOfMessagesToRetrieve = min(sortedChatFields.count, 30)
                    let recentChatFields = Array(sortedChatFields.suffix(numberOfMessagesToRetrieve))
                    
                    // 모델 타입으로 변환
                    return self.convertToChatMessageArray(from: recentChatFields)
                } else {
                    return []
                }
            }
            .asObservable()
    }
    
    //추가 30개 가져오기
    public func getMoreChatMessage(num: Int, coupleID: String, searchText searchGText: String?) -> Observable<[ChatMessage]> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .compactMap { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]], !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    
                

                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = self.dateFromFirestoreValue(dict1["date"]),
                              let date2 = self.dateFromFirestoreValue(dict2["date"]) else {
                            return false
                        }
                        return date1 > date2
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
                    
                    
                    // 모델 타입으로 변환
                    return self.convertToChatMessageArray(from: Array(recentChatFields))
                } else {
                    return []
                }
            }
            .asObservable()
    }
    
    // MARK: by seungwan
    public func getMessageSearch(coupleID: String, searchGText: String, num: Int) -> Observable<([ChatMessage],String)> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .compactMap { documentSnapshot in
                var findChatFields: [ChatDTO] = []
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]], !chatFields.isEmpty{
                    // 타임스탬프를 이용하여 날짜 순으로 정렬한다.
                    self.lastSearchedMessageID = ""
                

                    let sortedChatFields = chatFields.sorted { (dict1, dict2) -> Bool in
                        guard let date1 = self.dateFromFirestoreValue(dict1["date"]),
                              let date2 = self.dateFromFirestoreValue(dict2["date"]) else {
                            return false
                        }
                        return date1 > date2
                    }
                    

                    //TODO: clean code
                    //MARK: DTO타입으로 형변환
                    let converted = Array(self.convertToChatDTOArray(from: sortedChatFields.reversed())[ num ..< sortedChatFields.count ])
                    

                    for (index, element) in converted.enumerated() {
                        
                    
                        
                        if let text = element.contents, text.contains(searchGText) {
                            if 5 >= converted.count - index {
                                findChatFields = Array(converted[ 0 ..< index + 1 ].reversed())
                                
                            } else {
                                findChatFields = Array(converted[ 0 ..< index + 1 ].reversed())

                            }
                       
                            self.lastSearchedMessageID = element.messageId
                            break

                        }
                    }
                
                    
                }
                return (self.convertToChatMessageArray(from: findChatFields), self.lastSearchedMessageID ?? "")

            }
            .asObservable()
    }
    
    public func downloadImage(url: String) -> Single<Data?> {
        return self.firebaseService.downloadImage(urlString: url)
    }
    
    // 딕셔너리로 가져온 데이터 [DTO] 로 변환
    private func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO] {
        var chatDTOArray: [ChatDTO] = []
        
        for dictionary in dictionaries {
            guard let chatType = dictionary["chatType"] as? String,
                  let userId = dictionary["userId"] as? String,
                  let messageId = dictionary["messageId"] as? String,
                  let date = dateFromFirestoreValue(dictionary["date"]) else {
                continue
            }

            let contents = dictionary["contents"] as? String
            let chatDTO = ChatDTO(chatType: chatType, contents: contents, userId: userId, messageId: messageId, date: date)
            chatDTOArray.append(chatDTO)
        }
        return chatDTOArray
    }
    
    private func convertToChatMessageArray(from dictionaries: [[String: Any]]) -> [ChatMessage] {
        return convertToChatMessageArray(from: convertToChatDTOArray(from: dictionaries))
    }
    
    private func convertToChatMessageArray(from dtos: [ChatDTO]) -> [ChatMessage] {
        let messages = dtos.map { dto -> ChatMessage in
            return dto.toMessage()
        }
        return messages.sorted(by: { $0.sentDate < $1.sentDate })
    }
    
    public func getChatImagesURL(coupleID: String) -> Single<[String]> {
        return self.firebaseService.getDocument(collection: .Chat, document: coupleID)
            .map { documentSnapshot in
                if let chatFields = documentSnapshot["chatField"] as? [[String: Any]], !chatFields.isEmpty {
                    let chatArray = self.convertToChatDTOArray(from: chatFields)
                    return chatArray.filter({ $0.chatType == ChatType.image.stringType }).compactMap({ $0.contents })
                } else {
                    return []
                }
            }
            
    }

    private func chatValues(from dto: ChatDTO) -> [String: Any] {
        var values: [String: Any] = [
            "chatType": dto.chatType,
            "userId": dto.userId,
            "messageId": dto.messageId,
            "date": Timestamp(date: dto.date)
        ]

        if let contents = dto.contents {
            values["contents"] = contents
        }

        return values
    }

    private func dateFromFirestoreValue(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        if let dict = value as? [String: Any] {
            return dateFromTimestampDictionary(dict)
        }

        if let dict = value as? [String: Int] {
            let anyDict = dict.reduce(into: [String: Any]()) { result, entry in
                result[entry.key] = entry.value
            }
            return dateFromTimestampDictionary(anyDict)
        }

        return nil
    }

    private func dateFromTimestampDictionary(_ dict: [String: Any]) -> Date? {
        guard let seconds = numberValue(dict["seconds"]),
              let nanoseconds = numberValue(dict["nanoseconds"]) else {
            return nil
        }

        let interval = seconds + (nanoseconds / 1_000_000_000)
        return Date(timeIntervalSince1970: interval)
    }

    private func numberValue(_ value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let double = value as? Double {
            return double
        }
        if let int = value as? Int {
            return Double(int)
        }
        if let int64 = value as? Int64 {
            return Double(int64)
        }
        if let string = value as? String {
            return Double(string)
        }
        return nil
    }

}
