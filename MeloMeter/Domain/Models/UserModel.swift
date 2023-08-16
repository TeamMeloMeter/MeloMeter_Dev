//
//  UserModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

public enum GenderType: String {
    case male, female, cancel
    
    var stringType: String {
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

struct UserModel: Equatable, Hashable {

    // MARK: - Properties
    var uid: String?
    var otherUid: String?
    var coupleID: String?
    var phoneNumber: String?
    var profileImage: String?
    var name: String?
    var birth: Date?
    var stateMessage: String?
    var gender: GenderType?
    var createdAt: Date?
    
    init(uid: String?, otherUid: String?, coupleID: String?, phoneNumber: String?, profileImage: String?,name: String?, birth: Date?, stateMessage: String?, gender: GenderType?, createdAt: Date?) {
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
    
    init(name: String?, birth: Date?) {
        self.init(uid: nil, otherUid: nil, coupleID: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: nil, gender: nil, createdAt: nil)
        self.name = name
        self.birth = birth
    }
    
    init(name: String?, stateMessage: String?, birth: Date?, gender: GenderType?) {
        self.init(uid: nil, otherUid: nil, coupleID: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: stateMessage, gender: gender, createdAt: nil)
    }
    
    // MARK: - Methods
    func toProfileInsertDTO() -> UserDTO {
        return UserDTO(
            uid: UserDefaults.standard.string(forKey: "uid") ?? "",
            otherUid: otherUid,
            coupleID: coupleID,
            phoneNumber: UserDefaults.standard.string(forKey: "phoneNumber") ?? "",
            profileImagePath: profileImage,
            name: name ?? "",
            birth: birth?.toString(type: .yearToDay) ?? "",
            stateMessage: stateMessage, 
            gender: gender?.stringType,
            createdAt: createdAt?.toString(type: .timeStamp)
        )
    }
}
