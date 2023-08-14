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
    let uid: String
    let otherUid: String?
    let phoneNumber: String
    let profileImagePath: String?
    let name: String
    let birth: String
    let stateMessage: String?
    let gender: String?
    
    // MARK: - Methods
    func toModel() -> UserModel {
        return UserModel(
            uid: uid,
            otherUid: otherUid,
            phoneNumber: phoneNumber,
            profileImage: profileImagePath,
            name: name,
            birth: Date.fromStringOrNow(birth, .yearToDay),
            stateMessage: stateMessage ?? "상태메세지를 변경해보세요!",
            gender: gender == "남" ? .male : .female
        )
    }
}
