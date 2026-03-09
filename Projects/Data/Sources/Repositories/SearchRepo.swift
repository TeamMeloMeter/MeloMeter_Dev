//
//  SearchRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import Foundation
import Alamofire
import RxSwift
#if canImport(Domain)
import Domain
#endif

// MARK: - SearchedModel
public struct SearchedDto: Codable {
    public let lastBuildDate: String
    public let total, start, display: Int
    public let items: [SearchedItem]
    
}

// MARK: - Item
public struct SearchedItem: Codable {
    public var title: String
    public let link: String
    public let category, description, telephone, address: String
    public let roadAddress, mapx, mapy: String
    
}

public final class SearchRepo: SearchRepoP {
    public init() {}

    public func searchNaverAPI(text: String) -> Single<[SearchedModel]> {
        
        return Single.create { single in
            
            var coordinate = ","
            let header: HTTPHeaders = [
                "X-Naver-Client-Id": "1S4rXZBd_uSc93aBmW6I",
                "X-Naver-Client-Secret": "qTh3Hnm6CR",
            ]
            
            let display = 10
            
            AF.request ("https://openapi.naver.com/v1/search/local.json?query=\(text)&display=\(display)", method: .get, encoding: URLEncoding.default, headers: header) .validate(statusCode: 200..<300).responseDecodable(of: SearchedDto.self) { response in
                switch response.result {
                case .success(let dto):
                    
                    let models = dto.items.map {
                        SearchedModel(title: $0.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                                      , link: $0.link, category: $0.category, description: $0.description, telephone: $0.telephone, address: $0.address, roadAddress: $0.roadAddress, mapx: Double($0.mapx)! / 1e7, mapy: Double($0.mapy)! / 1e7 )
                        
                    }
                    
                    single(.success(models))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        
        
    }
    
}
