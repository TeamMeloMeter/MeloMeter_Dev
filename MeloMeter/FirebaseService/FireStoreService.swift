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
    
    func getDocument(collection: FireStoreCollection) -> Single<[FirebaseData]>
    func getCurrentUser() -> Single<User> //로그인된 사용자 정보 get
    func getDocument(collection: FireStoreCollection, document: String) -> Single<FirebaseData>
    func getDocument(collection: FireStoreCollection, field: String, values: [Any]) -> Single<[FirebaseData]> //필드:값 일치 문서 찾기
    func createDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void> //FireStore 추가
    
//    func getDocument(collection: FireStoreCollection, document: String) -> Single<FirebaseData>
//    func getDocument(collection: FireStoreCollection, field: String, condition: [String]) -> Single<[FirebaseData]>
//    func getDocument(collection: FireStoreCollection, field: String, in values: [Any]) -> Single<[FirebaseData]>
//    func getDocument(documents: [String]) -> Single<FirebaseData>
//    func createDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void>
//    func createDocument(documents: [String], values: FirebaseData) -> Single<Void>
//    func updateDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void>
//    func deleteDocument(collection: FireStoreCollection, document: String) -> Single<Void>
//    func observer(collection: FireStoreCollection, document: String) -> Observable<FirebaseData>
//    func observer(documents: [String]) -> Observable<FirebaseData>
//
//    // MARK: - Added
//    func getDocuments(documents: [String]) -> Single<[FirebaseData]>
//    func observe(documents: [String]) -> Observable<[FirebaseData]>
//    func observe(collection: FireStoreCollection, field: String, in values: [Any]) -> Observable<[FirebaseData]>
//    func deleteDocument(documents: [String]) -> Single<Void>
//    func deleteDocuments(collections: [(FireStoreCollection, String)]) -> Single<Void>
}
