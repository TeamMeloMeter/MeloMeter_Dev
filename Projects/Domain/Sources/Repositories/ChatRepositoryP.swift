//
//  ChatRepositoryP.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import RxSwift
import RxRelay

public protocol ChatRepositoryP {
    var recieveChatMessage: PublishSubject<[ChatMessage]?> { get set }

    func addChatMessage(message: ChatMessage, coupleID: String) -> Single<Void>
    func addImageMessage(chatMessage: ChatMessage, coupleID: String) -> Single<Void>
    func getRealTimeChat(coupleID: String)
    func getChatMessage(coupleID: String) -> Observable<[ChatMessage]>
    func getMoreChatMessage(num: Int, coupleID: String, searchText: String?) -> Observable<[ChatMessage]>
    func getChatImagesURL(coupleID: String) -> Single<[String]>
    func getMessageSearch(coupleID: String, searchGText: String, num: Int) -> Observable<([ChatMessage],String)>
}
