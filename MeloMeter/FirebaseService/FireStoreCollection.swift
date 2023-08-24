//
//  FireStoreCollection.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/07.
//

import Foundation

public enum FireStoreCollection: String {
    case Users, Couples, Locations, Chat, QusestionList
    
    var name: String {
        return self.rawValue
    }
}
