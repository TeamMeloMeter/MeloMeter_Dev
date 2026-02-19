//
//  VersionRepository.swift
//  MeloMeter
//
//  Created by 양승완 on 3/29/25.
//

import Foundation
import Domain

public class VersionService {
    
    public static let shared = VersionService()
    private init() {}
    
    public func getAppStoreVersion(completion: @escaping (String?) -> Void) {
        let bundleID = Bundle.main.bundleIdentifier
        guard let url = URL(string: "http://itunes.apple.com/kr/lookup?bundleId=\(bundleID ?? "")") else {
            
            completion(nil)
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion("offline")
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let appStoreVersion = results.first?["version"] as? String {
                completion(appStoreVersion)
            } else {
                completion(nil)
            }
        }.resume()
    }

    
    public func getDeviceVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
}
