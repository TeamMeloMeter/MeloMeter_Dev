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
    let latitude: Double
    let longitude: Double
    let imageUrls: [String]
    let createdAt: String
    
    func toDictionary() -> [String: Any] {
        return ["uuid": uuid,"title":title, "name": name, "description": description,  "latitude": latitude, "longitude": longitude, "imageUrls": imageUrls, "createdAt": createdAt ]
    }
}
