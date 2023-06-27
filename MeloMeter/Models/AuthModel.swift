//
//  AuthModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/26.
//

import UIKit
import Firebase
import FirebaseAppCheck

//전화번호 인증 모델
class AuthModel {
    var phoneNum = ""
    //var authID = ""
    
    func sendNumber() {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("\(phoneNum)", uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let id = verificationID { // id 저장
                    //self.authID = id
                    //print("UserDefaults: \(self.authID)")
                    UserDefaults.standard.set("\(id)", forKey: "verificationID")
                }
                
            }
    }
    
}
