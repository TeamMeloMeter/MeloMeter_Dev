//
//  ChatDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import Firebase

struct ChatDTO: Codable {

// MARK: - Properties
    let text: String?
    let userId: String
    let messageId: String
    let date: Date


// MARK: - Methods
//    func toModel() -> MockMessage {
//        return MockMessage(
//            text: text ?? "",
//            user: MockUser,// userId(uuid)를 이용해서 MockUser타입으로 리턴 해주는 매서드 필요
//            messageId: messageId,
//            date: date//타임스탬프를 데이트형태로 바꿔주는 작업이 필요
//        )
//    }
    
}
