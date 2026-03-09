//
//  UserDefaultsRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 4/8/25.
//

import Foundation
#if canImport(Domain)
import Domain
#endif

public class UserDefaultsRepo {
    public static let shared = UserDefaultsRepo()

    private init() {}
    
    
    private let userDefaultsStrings = ["otherUid", "uid", "phoneNumber", "name", "coupleID", "inviteCode", "otherFcmToken", "accessLevel", "createdAt", "birth", "name"]
    
    public func resetAllUserDefaults() {
        
        userDefaultsStrings.forEach {
            UserDefaults.standard.set(nil, forKey: $0)

        }
        
    }
    
    

    
    public func persistent(document: [String: Any?]) -> AccessLevel {
        let userDefaults = UserDefaults.standard

            let authenticatedKeys = [
                "accessLevel", "createdAt", "fcmToken", "inviteCode", "phoneNumber", "uid"
            ]
            let coupleCombinedKeys = ["coupleID", "otherFcmToken", "otherUid"]
            let completeOnlyKeys = ["birth", "name"]
            let allKeys = authenticatedKeys + coupleCombinedKeys + completeOnlyKeys + ["profileImagePath"]

            var missingKeys: [String] = []

            for key in allKeys {
                if let value = document[key], let strdValue = value as? String , !strdValue.isEmpty {
                    userDefaults.set(value, forKey: key)
                } else {
                    missingKeys.append(key)
                    print("nil or empty \(key)")

                }
            }

            // 1. Authenticated 항목이 누락되어 있으면 → authenticated
            if missingKeys.contains(where: { authenticatedKeys.contains($0) }) {
                return .none
            }

            // 2. CoupleCombined 항목이 누락되어 있으면 → coupleCombined
            if missingKeys.contains(where: { coupleCombinedKeys.contains($0) }) {
                return .authenticated
            }

            // 3. Complete 전용 항목이 누락되어 있으면 → complete 불가능
            if missingKeys.contains(where: { completeOnlyKeys.contains($0) }) {
                return .coupleCombined
            }

            // 4. 아무 것도 누락된 게 없으면 → complete
            return .complete
    }
}
