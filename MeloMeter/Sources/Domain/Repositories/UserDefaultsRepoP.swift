//
//  UserDefaultsReposutiryP.swift
//  MeloMeter
//
//  Created by 양승완 on 4/8/25.
//

protocol UserDefaultsRepoP {
    func persistUserSessionData(fcmToken: Any?, otherUid: Any?, coupleID: Any?, phoneNumber: Any?, uid: Any?) -> Bool
    func resetAllUserDefaults()
    
}
