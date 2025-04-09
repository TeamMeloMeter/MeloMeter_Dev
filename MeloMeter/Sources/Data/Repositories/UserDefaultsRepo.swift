//
//  UserDefaultsRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 4/8/25.
//

import Foundation

class UserDefaultsRepo: UserDefaultsRepoP {
    
    private let userDefaultsStrings = ["fcmToken", "otherUid", "coupleID", "uid", "phoneNumber","userName","coupleDocumentID","inviteCode","otherFcmToken"]
    
    func resetAllUserDefaults() {
        
        userDefaultsStrings.forEach {
            UserDefaults.standard.set(nil, forKey: $0)

        }
        
    }
    
    func persistUserSessionData(fcmToken: Any?, otherUid: Any?, coupleID: Any?, phoneNumber: Any?, uid: Any?) -> Bool {
        
        guard let fcmToken = fcmToken as? String,let otherUid = otherUid as? String, let coupleID = coupleID as? String, let phoneNumber = phoneNumber as? String, let uid = uid as? String else {return false}
        
        if fcmToken.isEmpty || otherUid.isEmpty || coupleID.isEmpty || phoneNumber.isEmpty || uid.isEmpty {
            
            return false
        } else {
            UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
            UserDefaults.standard.set(otherUid, forKey: "otherUid")
            UserDefaults.standard.set(coupleID, forKey: "coupleID")
            UserDefaults.standard.set(uid, forKey: "uid")
            UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
            
            return true
        }
        
       
    }
}
