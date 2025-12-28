//
//  CouplePlaceModel.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation

public struct CouplePlaceModel {
    public let category: String
    public let name: String
    public let description: String
    public let mapX: Double
    public let mapY: Double
    public let roadAddress: String
    public let address: String
    
    public let imagesDatas: [Data]?
    public var imageURLs: [String]?
    
    public var uuid: String?
    public var createdAt: String?
  
    public init(category: String, name: String, description: String, mapX: Double, mapY: Double, roadAddress: String, address: String, imagesDatas: [Data]? = nil, imageURLs: [String]? = nil, uuid: String? = nil, createdAt: String? = nil) {
        self.category = category
        self.name = name
        self.description = description
        self.mapX = mapX
        self.mapY = mapY
        self.imagesDatas = imagesDatas
        self.roadAddress = roadAddress
        self.address = address
        self.imageURLs = imageURLs
        self.uuid = uuid
        self.createdAt = createdAt
    }
}
