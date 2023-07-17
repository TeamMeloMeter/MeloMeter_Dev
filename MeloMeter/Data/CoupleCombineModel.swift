//
//  CoupleCombineModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/15.
//

import Foundation

public enum CombineError: Error {
    case falure
    case success
}

struct CoupleCombineModel: Equatable, Hashable {
    let uid1: String
    let phoneNumber1: String
    let uid2: String
    let phoneNumber2: String
    let createdAt: Date
}
