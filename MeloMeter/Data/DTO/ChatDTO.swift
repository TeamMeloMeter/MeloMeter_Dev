//
//  ChatDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChatDTO: Codable {

// MARK: - Properties
    let text: String?
    let userId: String
    let messageId: String
    let date: Timestamp


    // MARK: - Date 형을 firestore에 입력하면 Unix Time Stamp형으로 변환하는 작업

    private enum CodingKeys: String, CodingKey {
        case text
        case userId
        case messageId
        case date
    }
    
    func toModel() ->MockMessage {
        return MockMessage(
            text: text ?? "",
            user: MockUser(senderId: userId, displayName: ""),
            messageId: messageId,
            date: date.dateValue()
        )
    }

    
}
