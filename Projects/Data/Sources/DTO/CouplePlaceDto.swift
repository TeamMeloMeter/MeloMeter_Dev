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

public struct DatePlanDto: Codable {
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
    public let checkIns: [String: String]
    public let arrivalRecords: [String: String]
    public let isOnTime: Bool?
    public let isCompleted: Bool?

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
                radiusMeters: Double,
                dwellSeconds: Int,
                checkIns: [String: String],
                arrivalRecords: [String: String],
                isOnTime: Bool?,
                isCompleted: Bool?) {
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

    public func toDictionary() -> [String: Any] {
        var values: [String: Any] = [
            "uuid": uuid,
            "name": name,
            "memo": memo,
            "mapX": mapX,
            "mapY": mapY,
            "roadAddress": roadAddress,
            "address": address,
            "scheduledAt": scheduledAt,
            "createdAt": createdAt,
            "createdBy": createdBy,
            "notifyEnabled": notifyEnabled,
            "radiusMeters": radiusMeters,
            "dwellSeconds": dwellSeconds,
            "checkIns": checkIns,
            "arrivalRecords": arrivalRecords
        ]
        if let isOnTime {
            values["isOnTime"] = isOnTime
        }
        if let isCompleted {
            values["isCompleted"] = isCompleted
        }
        return values
    }
}
