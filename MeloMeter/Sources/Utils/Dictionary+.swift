//
//  Dictionary+.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/14.
//

import Foundation

extension Dictionary<String, Any> {
    
    func toObject<T>() -> T? where T: Decodable {
        guard
            let data = try? JSONSerialization.data(withJSONObject: self),
            let object = try? JSONDecoder().decode(T.self, from: data)
        else {
            return nil
        }
        
        return object
    }
    
    func toObject<T>(_ type: T.Type) -> T? where T: Decodable {
        return self.toObject()
    }
}
