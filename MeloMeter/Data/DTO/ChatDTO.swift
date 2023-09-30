//
//  ChatDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import MessageKit

enum ChatType: String, Codable {
    case text
    case image
    
    var stringType: String {
            switch self {
            case .text:
                return "text"
            case .image:
                return "image"
            }
        }
}

struct ChatDTO: Codable {

// MARK: - Properties
    
    let chatType: String
    let contents: String?
    let userId: String
    let messageId: String
    let date: Timestamp

    
//     MARK: - Date 형을 firestore에 입력하면 Unix Time Stamp형으로 변환하는 작업
    func toModel() ->MockMessage {
        
        return MockMessage(
            text: contents ?? "",
            user: MockUser(senderId: userId, displayName: ""),
            messageId: messageId,
            date: date.dateValue()
        )
    }
    
    func toModel(image: UIImage) ->MockMessage {
        return MockMessage(
            image: image,
            user: MockUser(senderId: userId, displayName: ""),
            messageId: messageId,
            date: date.dateValue()
        )
    }

    
}
