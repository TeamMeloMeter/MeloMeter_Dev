//
//  UserModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

public enum GenderType: String {
    case male, female, cancel
    
    public var stringType: String {
        switch self {
        case .male:
            return "남"
        case .female:
            return "여"
        default:
            return "남"
        }
    }
}

public struct UserModel: Equatable, Hashable {

    // MARK: - Properties
    public var fcmToken: String?
    public var uid: String?
    public var otherUid: String?
    public var coupleID: String?
    public var phoneNumber: String?
    public var profileImage: String?
    public var name: String?
    public var birth: Date?
    public var stateMessage: String?
    public var gender: GenderType?
    public var createdAt: Date?
    
    public init(fcmToken: String?, uid: String?, otherUid: String?, coupleID: String?, phoneNumber: String?, profileImage: String?,name: String?, birth: Date?, stateMessage: String?, gender: GenderType?, createdAt: Date?) {
        self.fcmToken = fcmToken
        self.uid = uid
        self.otherUid = otherUid
        self.coupleID = coupleID
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.name = name
        self.birth = birth
        self.stateMessage = stateMessage
        self.gender = gender
        self.createdAt = createdAt
    }
    
    public init(name: String?, birth: Date?) {
        self.init(fcmToken: nil, uid: nil, otherUid: nil, coupleID: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: nil, gender: nil, createdAt: nil)
        self.name = name
        self.birth = birth
    }
    
    public init(name: String?, stateMessage: String?, birth: Date?, gender: GenderType?) {
        self.init(fcmToken: nil, uid: nil, otherUid: nil, coupleID: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: stateMessage, gender: gender, createdAt: nil)
    }

}
