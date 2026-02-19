//
//  SearchedModel.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import Foundation

public struct SearchedModel {
    public var title: String
    public let link: String
    public let category: String
    public let description: String
    public let telephone: String
    public let address: String
    public let roadAddress: String
    public let mapx: Double
    public let mapy: Double

    public init(
        title: String,
        link: String,
        category: String,
        description: String,
        telephone: String,
        address: String,
        roadAddress: String,
        mapx: Double,
        mapy: Double
    ) {
        self.title = title
        self.link = link
        self.category = category
        self.description = description
        self.telephone = telephone
        self.address = address
        self.roadAddress = roadAddress
        self.mapx = mapx
        self.mapy = mapy
    }
}
