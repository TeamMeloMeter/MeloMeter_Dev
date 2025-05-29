//
//  CouplePlaceModel.swift
//  MeloMeter
//
//  Created by 양승완 on 5/27/25.
//

import Foundation

struct CouplePlaceModel {
    let category: String
    let name: String
    let description: String
    let mapX: Double
    let mapY: Double
    let roadAddress: String
    let address: String
    
    let imagesDatas: [Data]?
    var imageURLs: [String]?
    
    var uuid: String?
    var createdAt: String?
  
    init(category: String, name: String, description: String, mapX: Double, mapY: Double, roadAddress: String, address: String, imagesDatas: [Data]? = nil, imageURLs: [String]? = nil, uuid: String? = nil, createdAt: String? = nil) {
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
