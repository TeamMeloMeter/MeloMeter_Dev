//
//  UserDefaultsRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 4/8/25.
//

import Foundation
import os
import FirebaseFirestore
import Domain

public class UserDefaultsRepo {
    public static let shared = UserDefaultsRepo()
    #if DEBUG
    private let logger = Logger(subsystem: "com.teamMeloMeter", category: "UserDefaultsRepo")
    #endif

    private init() {}
    
    
    private let userDefaultsStrings = ["fcmToken", "otherUid", "uid", "phoneNumber","name","coupleID","inviteCode","otherFcmToken","accessLevel","createdAt","birth", "name"]
    
    public func resetAllUserDefaults() {
        
        userDefaultsStrings.forEach {
            UserDefaults.standard.set(nil, forKey: $0)

        }
        
    }
    
    

    
    public func persistent(document: [String: Any]) -> AccessLevel {
        let userDefaults = UserDefaults.standard

            let authenticatedKeys = [
                "createdAt", "fcmToken", "inviteCode", "phoneNumber", "uid"
            ]
            let coupleCombinedKeys = ["coupleID", "otherFcmToken", "otherUid"]
            let completeOnlyKeys = ["birth", "name"]
            let allKeys = authenticatedKeys + coupleCombinedKeys + completeOnlyKeys + ["profileImagePath"]

            var missingKeys: [String] = []

            for key in allKeys {
                let value = value(for: key, in: document)
                if let strdValue = stringValue(for: key, from: value) {
                    userDefaults.set(strdValue, forKey: key)
                } else {
                    missingKeys.append(key)
                    print("nil or empty \(key)")

                }
            }

            // 1. Authenticated 항목이 누락되어 있으면 → authenticated
            let derivedLevel: AccessLevel
            if missingKeys.contains(where: { authenticatedKeys.contains($0) }) {
                derivedLevel = .none
            } else if missingKeys.contains(where: { coupleCombinedKeys.contains($0) }) {
                // 2. CoupleCombined 항목이 누락되어 있으면 → coupleCombined
                derivedLevel = .authenticated
            } else if missingKeys.contains(where: { completeOnlyKeys.contains($0) }) {
                // 3. Complete 전용 항목이 누락되어 있으면 → complete 불가능
                derivedLevel = .coupleCombined
            } else {
                // 4. 아무 것도 누락된 게 없으면 → complete
                derivedLevel = .complete
            }

            let resolvedLevel: AccessLevel
            if let storedLevel = accessLevel(from: document["accessLevel"]) {
                resolvedLevel = maxLevel(storedLevel, derivedLevel)
            } else {
                resolvedLevel = derivedLevel
            }

            userDefaults.set(resolvedLevel.toString, forKey: "accessLevel")
            #if DEBUG
            let accessLevelField = document["accessLevel"] as? String ?? "nil"
            let nameType = value(for: "name", in: document).map { String(describing: type(of: $0)) } ?? "nil"
            let birthType = value(for: "birth", in: document).map { String(describing: type(of: $0)) } ?? "nil"
            logger.notice("persistent: accessLevelField=\(accessLevelField, privacy: .public) derived=\(derivedLevel.rawValue, privacy: .public) resolved=\(resolvedLevel.rawValue, privacy: .public)")
            logger.notice("persistent: missingKeys=\(missingKeys.joined(separator: ","), privacy: .public)")
            logger.notice("persistent: nameType=\(nameType, privacy: .public) birthType=\(birthType, privacy: .public)")
            let debugSummary = "accessLevelField=\(accessLevelField) derived=\(derivedLevel.rawValue) resolved=\(resolvedLevel.rawValue) missingKeys=\(missingKeys.joined(separator: ",")) nameType=\(nameType) birthType=\(birthType)"
            userDefaults.set(debugSummary, forKey: "accessLevelDebug")
            #endif
            return resolvedLevel
    }

    private func value(for key: String, in document: [String: Any]) -> Any? {
        switch key {
        case "name":
            return document["name"]
                ?? document["userName"]
                ?? document["username"]
                ?? document["user_name"]
        case "birth":
            return document["birth"]
                ?? document["birthDay"]
                ?? document["birthday"]
                ?? document["birthDate"]
        default:
            return document[key]
        }
    }

    private func stringValue(for key: String, from value: Any?) -> String? {
        if let string = value as? String, !string.isEmpty {
            return string
        }

        if key == "birth" {
            if let date = value as? Date {
                return date.toString(type: .yearToDay)
            }
            if let timestamp = value as? Timestamp {
                return timestamp.dateValue().toString(type: .yearToDay)
            }
        }

        if key == "createdAt" {
            if let date = value as? Date {
                return date.toString(type: .timeStamp)
            }
            if let timestamp = value as? Timestamp {
                return timestamp.dateValue().toString(type: .timeStamp)
            }
        }

        return nil
    }

    private func accessLevel(from value: Any?) -> AccessLevel? {
        guard let string = value as? String else {
            return nil
        }

        return AccessLevel(rawValue: string)
    }

    private func maxLevel(_ lhs: AccessLevel, _ rhs: AccessLevel) -> AccessLevel {
        return levelRank(lhs) >= levelRank(rhs) ? lhs : rhs
    }

    private func levelRank(_ level: AccessLevel) -> Int {
        switch level {
        case .none:
            return 0
        case .start:
            return 1
        case .authenticated:
            return 2
        case .coupleCombined:
            return 3
        case .complete:
            return 4
        }
    }
}
