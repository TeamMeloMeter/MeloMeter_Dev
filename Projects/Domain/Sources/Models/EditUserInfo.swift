//
//  EditUserInfo.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation

public enum EditUserInfo: String {
    case profileImage, name, birth, stateMessage, gender
    
    public var field: String {
        return self.rawValue
    }
}
