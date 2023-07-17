//
//  DefaultFirebaseService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/07.
//

import Foundation
import Firebase
import RxSwift

public enum FireStoreError: Error, LocalizedError {
    case unknown
    case decodeError
}

public final class DefaultFirebaseService: FireStoreService {
    
    
    private let database: Firestore
    
    public init(
        firestore: Firestore = Firestore.firestore(),
        allowsCaching: Bool = true
    ) {
        if !allowsCaching {
            let setting = Firestore.firestore().settings
            setting.isPersistenceEnabled = false
            firestore.settings = setting
        }
        
        self.database = firestore
    }
    
//    public func getCurrentUser(field: String) -> Single<String?> {
//        return Single.create { single in
//            if field == "UID" {
//                guard let uid = Auth.auth().currentUser?.uid else { single(.success(nil)); return Disposables.create() }
//                single(.success(uid))
//            }else if field == "PhoneNumber" {
//                guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else { single(.success(nil)); return Disposables.create() }
//                single(.success(phoneNumber))
//            }
//            return Disposables.create()
//        }
//    }
    public func getCurrentUser() -> Single<User> {
        return Single.create { single in
            guard let currentUser = Auth.auth().currentUser else{ return Disposables.create()}
            single(.success(currentUser))
            return Disposables.create()
        }
    }
    public func getDocument(collection: FireStoreCollection, document: String) -> Single<FirebaseData> {
        return Single<FirebaseData>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.database.collection(collection.name).document(document).getDocument { snapshot, error in
                if let error = error { single(.failure(error)) }
                
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    single(.failure(FireStoreError.unknown))
                    return
                }
                single(.success(data))
            }
            return Disposables.create()
        }
    }
    
    public func getDocument(collection: FireStoreCollection, field: String, values: [Any]) -> Single<[FirebaseData]> {// [String: Any]
        return Single.create { [weak self] single in
                    guard let self else { return Disposables.create() }
                    
                    var queries = values
                    if queries.isEmpty { queries.append("") }
                    
                    self.database.collection(collection.name)
                        .whereField(field, in: queries)
                        .getDocuments { snapshot, error in
                            if let error = error { single(.failure(error)) }
                            
                            guard let snapshot = snapshot else {
                                single(.failure(FireStoreError.unknown))
                                return
                            }
                            let data = snapshot.documents.map { $0.data() }
                            single(.success(data))
                        }
                    return Disposables.create()
                }
    }
    
    public func createDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            var newDocument: DocumentReference
            
            if document == "" { //문서ID 자동생성
                newDocument = self.database.collection(collection.name)
                    .document()
            }else { //문서ID 지정생성
                newDocument = self.database.collection(collection.name)
                    .document(document)
            }
            
            newDocument.setData(values) { error in
                if let error = error { single(.failure(error)) }
                single(.success(()))
            }
            
            return Disposables.create()
        }
    }

    
    
    
    
    public func getDocument(collection: FireStoreCollection) -> Single<[FirebaseData]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.database.collection(collection.name)
                .getDocuments { snapshot, error in
                    if let error = error { single(.failure(error)) }
                    
                    guard let snapshot = snapshot else {
                        single(.failure(FireStoreError.unknown))
                        return
                    }
                    
                    let data = snapshot.documents.map { $0.data() }
                    single(.success(data))
                }
            return Disposables.create()
        }
    }
  
    
    
}
