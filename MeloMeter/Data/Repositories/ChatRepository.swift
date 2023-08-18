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

class ChatRepository: ChatRepositoryP{
    
    let myCoupleid = UserDefaults.standard.string(forKey: "coupleDocumentID") ?? ""
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    // MockMessage타입을 인자로 받아서 fireBase에 insert하는 함수 / 리턴 t/f
    func addChatMessage(mockMessage: MockMessage) -> Single<Void> {
        let dto = mockMessage.toDTO()
        
        self.getChatMessage().subscribe(onNext: { result in
            print(result, " 성공")
        },onError: { Error in
            print(Error,"에러")
        }).disposed(by: self.disposeBag)

        
        let values = dto.asDictionary ?? [:]

        return self.firebaseService.updateDocument(collection: .Chat, document: myCoupleid, values: ["chatField" : FieldValue.arrayUnion([values]) ])
        
    }
    
    //최근 30개 가져오기
    func getChatMessage() -> Observable<ChatDTO> {
        self.firebaseService.getDocument(collection: .Chat, document: myCoupleid)
            .subscribe(onSuccess: { result in
                print(self.convertToChatDTOArray(from : result["chatField"] as! [[String : Any]]))
                
            }).disposed(by: self.disposeBag)
        
        return self.firebaseService.getDocument(collection: .Chat, document: myCoupleid)
            .compactMap{ $0.toObject(ChatDTO.self) }
            .asObservable()
    }
    
    func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO] {
        var chatDTOArray: [ChatDTO] = []

        for dictionary in dictionaries {
            if let text = dictionary["text"] as? String,
               let userId = dictionary["userId"] as? String,
               let messageId = dictionary["messageId"] as? String,
               let date = dictionary["date"] as? [String:Int]
            {
                let timestamp = Timestamp(seconds: Int64(date["seconds"] ?? 0), nanoseconds: Int32(date["nanoseconds"] ?? 0))
                
                //타임스탬프 데이트로 변환
//                print(timestamp.dateValue()," @@@@@@@@@@@")
                let chatDTO = ChatDTO(text: text, userId: userId, messageId: messageId, date: timestamp)
                chatDTOArray.append(chatDTO)
            }
        }
        return chatDTOArray
    }

}

