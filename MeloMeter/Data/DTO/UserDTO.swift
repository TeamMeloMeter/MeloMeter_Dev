//
//  UserDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

enum EditUserInfo: String {
    case profileImage, name, birth, stateMessage, gender
    
    var field: String {
        return self.rawValue
    }
}

struct UserDTO: Codable {
    
    // MARK: - Properties
    let fcmToken: String?
    let uid: String
    let otherUid: String?
    let coupleID: String?
    let phoneNumber: String
    let profileImagePath: String?
    let name: String
    let birth: String
    let stateMessage: String?
    let gender: String?
    let createdAt: String?
    
    // MARK: - Methods
    func toModel() -> UserModel {
        return UserModel(
            fcmToken: fcmToken,
            uid: uid,
            otherUid: otherUid,
            coupleID: coupleID,
            phoneNumber: phoneNumber,
            profileImage: profileImagePath,
            name: name,
            birth: Date.fromStringOrNow(birth, .yearToDay),
            stateMessage: stateMessage,
            gender: gender == "남" ? .male : .female,
            createdAt: Date.fromStringOrNow(createdAt ?? "", .timeStamp)
        )
    }
}
