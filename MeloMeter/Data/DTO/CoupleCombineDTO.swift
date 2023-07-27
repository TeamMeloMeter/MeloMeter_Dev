//
//  CoupleDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/14.
//

import Foundation

struct CoupleCombineDTO: Codable {
    
    // MARK: - Properties
    let uid1: String
    let phoneNumber1: String
    let uid2: String
    let phoneNumber2: String
    let createdAt: String
    
    // MARK: - Methods
    func toModel() -> CoupleCombineModel {
        return CoupleCombineModel(
            uid1: uid1,
            phoneNumber1: phoneNumber1,
            uid2: uid2,
            phoneNumber2: phoneNumber2,
            createdAt: Date.fromStringOrNow(createdAt)
        )
    }
}


