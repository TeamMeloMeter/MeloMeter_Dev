//
//  UserDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

public enum EditUserInfo: String {
    case profileImage, name, birth, stateMessage, gender
    
    public var field: String {
        return self.rawValue
    }
}

public struct UserDTO: Codable {
    
    // MARK: - Properties
    public let fcmToken: String?
    public let uid: String
    public let otherUid: String?
    public let coupleID: String?
    public let phoneNumber: String
    public let profileImagePath: String?
    public let name: String
    public let birth: String
    public let stateMessage: String?
    public let gender: String?
    public let createdAt: String?

    public init(fcmToken: String?, uid: String, otherUid: String?, coupleID: String?, phoneNumber: String, profileImagePath: String?, name: String, birth: String, stateMessage: String?, gender: String?, createdAt: String?) {
        self.fcmToken = fcmToken
        self.uid = uid
        self.otherUid = otherUid
        self.coupleID = coupleID
        self.phoneNumber = phoneNumber
        self.profileImagePath = profileImagePath
        self.name = name
        self.birth = birth
        self.stateMessage = stateMessage
        self.gender = gender
        self.createdAt = createdAt
    }
    
    // MARK: - Methods
    public func toModel() -> UserModel {
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
