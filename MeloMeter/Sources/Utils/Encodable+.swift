//
//  Encodable.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/14.
//

import Foundation

extension Encodable {
    
    var asDictionary: [String: Any]? {
        guard
            let object = try? JSONEncoder().encode(self),
            let dictinoary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String: Any]
        else {
            return nil
        }
        
        return dictinoary
    }
}
