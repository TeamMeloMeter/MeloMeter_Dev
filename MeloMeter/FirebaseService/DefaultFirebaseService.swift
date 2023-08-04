//
//  DefaultFirebaseService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/07.
//

import Foundation
import Firebase
import FirebaseFirestore
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
    
    public func getDocument(collection: FireStoreCollection, field: String, values: [Any]) -> Single<[FirebaseData]> {
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
            let documentID = newDocument.documentID
            newDocument.setData(values, merge: true) { error in
                if let error = error { single(.failure(error)) }
                single(.success(()))
            }
            if document == "" { UserDefaults.standard.set("\(documentID)", forKey: "coupleDocumentID") }

            return Disposables.create()
        }
    }
    
    
}

public extension DefaultFirebaseService {
    func observer(collection: FireStoreCollection, document: String) -> Observable<FirebaseData> {
        return Observable<FirebaseData>.create { [weak self] observable in
            guard let self else { return Disposables.create() }
            
            self.database.collection(collection.name)
                .document(document)
                .addSnapshotListener { snapshot, error in
                    //print("파베 옵저버: ", snapshot) // MARK: 상대 위치 가져올때 에러 - 원인: UserDefaults 대신 파베에서 검색해서 uid2 가져오기 *
                    if let error = error { observable.onError(error) }
                    
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        observable.onError(FireStoreError.unknown)
                        return
                    }
                    
                    observable.onNext(data)
                }
            return Disposables.create()
        }
    }
}
