//
//  ChatType.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation

public enum ChatType: String, Codable {
    case text
    case image
    
    public var stringType: String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        }
    }
}
