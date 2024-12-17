//
//  UserDefaultService.swift
//  MeloMeter
//
//  Created by 양승완 on 12/17/24.
//

import Foundation


enum UserDefaultKeys: String{
    case phoneNumber
    case fcmToken
    case uid
}

final class UserDefaultService {
    
    static let shared = UserDefaultService()
    
    
    func setDefault(key: UserDefaultKeys, val : Any) {
        UserDefaults.standard.set(val , forKey: key.rawValue)
    }
    
}
