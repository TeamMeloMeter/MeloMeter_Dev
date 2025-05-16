//
//  SearchRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import Foundation
import Alamofire

final class SearchRepo: SearchRepoP {
    func searchNaverAPI(text: String) {
            var coordinate = ","
            let header: HTTPHeaders = [
                "X-Naver-Client-Id": "1S4rXZBd_uSc93aBmW6I",
                "X-Naver-Client-Secret": "qTh3Hnm6CR",
            ]

            var display = 10
            let encodedSearchName = text.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        AF.request ("https://openapi.naver.com/v1/search/local.json?query=\(String(describing: encodedSearchName))&display=\(display)", method: .get, encoding: URLEncoding.default, headers: header) .validate(statusCode: 200..<300).responseJSON { (response) -> Void in

            print(response)
            }

        }
    
}
