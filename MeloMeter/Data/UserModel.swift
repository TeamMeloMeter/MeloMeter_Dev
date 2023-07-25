//
//  UserModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

struct UserModel: Equatable, Hashable {

    // MARK: - Properties
    var uid: String?
    var phoneNumber: String?
    var name: String?
    var birth: Date?
    var firstDay: Date?
    
    init(uid: String?, phoneNumber: String?, name: String?, birth: Date?, firstDay: Date?) {
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.name = name
        self.birth = birth
        self.firstDay = firstDay
    }
    
    init(name: String?, birth: Date?, firstDay: Date?) {
        self.init(uid: nil, phoneNumber: nil, name: name, birth: birth, firstDay: firstDay)
        self.name = name
        self.birth = birth
        self.firstDay = firstDay
    }
    
    // MARK: - Methods
    func toProfileInsertDTO() -> UserDTO {
        return UserDTO(
            uid: UserDefaults.standard.string(forKey: "uid") ?? "",
            phoneNumber: UserDefaults.standard.string(forKey: "phoneNumber") ?? "",
            name: name ?? "",
            birth: birth?.toString(type: .yearAndMonthAndDate) ?? "",
            firstDay: firstDay?.toString(type: .yearAndMonthAndDate) ?? ""
        )
    }
}
