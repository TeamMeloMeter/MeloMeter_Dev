//
//  FirestoreService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/07.
//

import Foundation
import RxSwift
import Firebase

public protocol FireStoreService {
    
    typealias FirebaseData = [String: Any]
    
    func getCurrentUser() -> Single<User> //로그인된 사용자 정보 get
    func getDocument(collection: FireStoreCollection, document: String) -> Single<FirebaseData>
    func getDocument(collection: FireStoreCollection, field: String, values: [Any]) -> Single<[FirebaseData]> //필드:값 일치 문서 찾기
    func createDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void> //FireStore 추가
    func updateDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void>
    func observer(collection: FireStoreCollection, document: String) -> Observable<FirebaseData>
    
    func uploadImage(image: UIImage) -> Single<String>
    func downloadImage(urlString: String) -> Single<UIImage?>
    func setAccessLevel(_ level: AccessLevel) -> Single<Void>

}
