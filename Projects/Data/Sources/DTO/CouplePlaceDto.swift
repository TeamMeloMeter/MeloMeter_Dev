//
//  CouplePlaceDto.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation

public struct CouplePlaceDto: Codable {
    public let address: String
    public let roadAddress: String
    public let uuid: String
    public let title: String
    public let name: String
    public let description: String
    public let mapX: Double
    public let mapY: Double
    public let imageUrls: [String]
    public let createdAt: String
    public let category: String

    public init(address: String, roadAddress: String, uuid: String, title: String, name: String, description: String, mapX: Double, mapY: Double, imageUrls: [String], createdAt: String, category: String) {
        self.address = address
        self.roadAddress = roadAddress
        self.uuid = uuid
        self.title = title
        self.name = name
        self.description = description
        self.mapX = mapX
        self.mapY = mapY
        self.imageUrls = imageUrls
        self.createdAt = createdAt
        self.category = category
    }
    
    public func toDictionary() -> [String: Any] {
        return ["uuid": uuid, "title":title, "name": name, "description": description,  "mapX": mapX, "mapY": mapY, "imageUrls": imageUrls, "createdAt": createdAt, "address": address, "roadAddress": roadAddress, "category": category]
    }
}
