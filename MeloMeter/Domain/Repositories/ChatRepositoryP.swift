//
//  ChatRepositoryP.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import RxSwift

protocol ChatRepositoryP {
    func addChatMessage(message: MockMessage, coupleID: String) -> Single<Void>
    func addImageMessage(mockMessage: MockMessage, coupleID: String) -> Single<Void>
    func getRealTimeChat(coupleID: String)
    func getChatMessage(coupleID: String) -> Observable<[ChatDTO]>
    func downloadImage(url: String) -> Single<UIImage?>
    func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO]
    func getChatImagesURL(coupleID: String) -> Single<[String]>
}
