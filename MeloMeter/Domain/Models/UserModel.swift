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
    var phoneNumber: String?
    var profileImage: String?
    var name: String?
    var birth: Date?
    var stateMessage: String?
    var gender: GenderType?
    
    init(uid: String?, otherUid: String?, phoneNumber: String?, profileImage: String?,name: String?, birth: Date?, stateMessage: String?, gender: GenderType?) {
        self.uid = uid
        self.otherUid = otherUid
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.name = name
        self.birth = birth
        self.stateMessage = stateMessage
        self.gender = gender
    }
    
    init(name: String?, birth: Date?) {
        self.init(uid: nil, otherUid: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: nil, gender: nil)
        self.name = name
        self.birth = birth
    }
    
    init(name: String?, stateMessage: String?, birth: Date?, gender: GenderType?) {
        self.init(uid: nil, otherUid: nil, phoneNumber: nil, profileImage: nil, name: name, birth: birth, stateMessage: stateMessage, gender: gender)
    }
    
    // MARK: - Methods
    func toProfileInsertDTO() -> UserDTO {
        return UserDTO(
            uid: UserDefaults.standard.string(forKey: "uid") ?? "",
            otherUid: otherUid,
            phoneNumber: UserDefaults.standard.string(forKey: "phoneNumber") ?? "",
            profileImagePath: profileImage,
            name: name ?? "",
            birth: birth?.toString(type: .yearToDay) ?? "",
            stateMessage: stateMessage, 
            gender: gender?.stringType
        )
    }
}
