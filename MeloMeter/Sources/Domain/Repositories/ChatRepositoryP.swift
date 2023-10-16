//
//  ChatRepositoryP.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import RxSwift
import RxRelay

protocol ChatRepositoryP {
    var recieveChatMessage: PublishSubject<[ChatDTO]?> { get set }
    
    func addChatMessage(message: ChatModel, coupleID: String) -> Single<Void>
    func addImageMessage(chatModel: ChatModel, coupleID: String) -> Single<Void>
    func getRealTimeChat(coupleID: String)
    func getChatMessage(coupleID: String) -> Observable<[ChatDTO]>
    func getMoreChatMessage(num: Int, coupleID: String) -> Observable<[ChatDTO]>
    func downloadImage(url: String) -> Single<UIImage?>
    func convertToChatDTOArray(from dictionaries: [[String: Any]]) -> [ChatDTO]
    func getChatImagesURL(coupleID: String) -> Single<[String]>
}
