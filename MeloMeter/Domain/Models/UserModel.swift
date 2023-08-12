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
    var phoneNumber: String?
    var name: String?
    var birth: Date?
    var stateMessage: String?
    var gender: GenderType?
    
    init(uid: String?, phoneNumber: String?, name: String?, birth: Date?, stateMessage: String?, gender: GenderType?) {
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.name = name
        self.birth = birth
        self.stateMessage = stateMessage
        self.gender = gender
    }
    
    init(name: String?, birth: Date?) {
        self.init(uid: nil, phoneNumber: nil, name: name, birth: birth, stateMessage: nil, gender: nil)
        self.name = name
        self.birth = birth
    }
    
    init(name: String?, stateMessage: String?, birth: Date?, gender: GenderType?) {
        self.init(uid: nil, phoneNumber: nil, name: name, birth: birth, stateMessage: stateMessage, gender: gender)
    }
    
    // MARK: - Methods
    func toProfileInsertDTO() -> UserDTO {
        return UserDTO(
            uid: UserDefaults.standard.string(forKey: "uid") ?? "",
            phoneNumber: UserDefaults.standard.string(forKey: "phoneNumber") ?? "",
            name: name ?? "",
            birth: birth?.toString(type: .yearToDay) ?? "",
            stateMessage: stateMessage,
            gender: gender?.stringType
        )
    }
}
