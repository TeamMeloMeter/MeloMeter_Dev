//
//  UserDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

struct UserDTO: Codable {
    
    // MARK: - Properties
    let uid: String
    let phoneNumber: String
    let name: String
    let birth: String
    let stateMessage: String?
    let gender: String?
    // MARK: - Methods
    func toModel() -> UserModel {
        return UserModel(
            uid: uid,
            phoneNumber: phoneNumber,
            name: name,
            birth: Date.fromStringOrNow(birth, .yearToDay),
            stateMessage: stateMessage ?? "",
            gender: gender ?? "남"
        )
    }
}
