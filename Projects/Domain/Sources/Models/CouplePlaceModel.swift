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

public struct DatePlanModel {
    public let uuid: String
    public let name: String
    public let memo: String
    public let mapX: Double
    public let mapY: Double
    public let roadAddress: String
    public let address: String
    public let scheduledAt: String
    public let createdAt: String
    public let createdBy: String
    public let notifyEnabled: Bool
    public let radiusMeters: Double
    public let dwellSeconds: Int
    public var checkIns: [String: String]
    public var arrivalRecords: [String: String]
    public var isOnTime: Bool?
    public var isCompleted: Bool?

    public init(uuid: String,
                name: String,
                memo: String,
                mapX: Double,
                mapY: Double,
                roadAddress: String,
                address: String,
                scheduledAt: String,
                createdAt: String,
                createdBy: String,
                notifyEnabled: Bool,
                radiusMeters: Double = 300,
                dwellSeconds: Int = 180,
                checkIns: [String: String] = [:],
                arrivalRecords: [String: String] = [:],
                isOnTime: Bool? = nil,
                isCompleted: Bool? = nil) {
        self.uuid = uuid
        self.name = name
        self.memo = memo
        self.mapX = mapX
        self.mapY = mapY
        self.roadAddress = roadAddress
        self.address = address
        self.scheduledAt = scheduledAt
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.notifyEnabled = notifyEnabled
        self.radiusMeters = radiusMeters
        self.dwellSeconds = dwellSeconds
        self.checkIns = checkIns
        self.arrivalRecords = arrivalRecords
        self.isOnTime = isOnTime
        self.isCompleted = isCompleted
    }
}
