//
//  CouplePlaceDto.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation

struct CouplePlaceDto: Codable {
    let uuid: String
    let title: String
    let name: String
    let description: String
    let mapX: Double
    let mapY: Double
    let imageUrls: [String]
    let createdAt: String
    
    func toDictionary() -> [String: Any] {
        return ["uuid": uuid,"title":title, "name": name, "description": description,  "mapX": mapX, "mapY": mapY, "imageUrls": imageUrls, "createdAt": createdAt ]
    }
}
