//
//  DefaultFirebaseService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/07.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import RxSwift

public enum FireStoreError: Error, LocalizedError {
    case unknown
    case decodeError
}

public final class DefaultFirebaseService: FirebaseService {
    
    
    private let database: Firestore
    private var disposeBag = DisposeBag()
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
            guard let currentUser = Auth.auth().currentUser else{
                single(.failure(FireStoreError.unknown))
                return Disposables.create()
            }
            single(.success(currentUser))
            return Disposables.create()
        }
    }
    
    public func getDocument(collection: FireStoreCollection, document: String) -> Single<FirebaseData> {
        return Single<FirebaseData>.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            self.database.collection(collection.name).document(document).getDocument { snapshot, error in
                if let error = error { single(.failure(error))
                }
                
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
                    guard let self = self else { return Disposables.create() }
                    
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
            guard let self = self else { return Disposables.create() }
            var newDocument: DocumentReference
            
            if document == "" { //문서ID 자동생성
                newDocument = self.database.collection(collection.name)
                    .document()
                UserDefaults.standard.set(newDocument.documentID, forKey: "coupleDocumentID")
            }else { //문서ID 지정생성
                newDocument = self.database.collection(collection.name)
                    .document(document)
            }
            newDocument.setData(values, merge: true) { error in
                if let error = error { single(.failure(error)) }
                single(.success(()))
            }

            return Disposables.create()
        }
    }
    
    public func updateDocument(collection: FireStoreCollection, document: String, values: FirebaseData) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            self.database.collection(collection.name)
                .document(document)
                .updateData(values) { error in
                    if let error = error { single(.failure(error)) }

                    single(.success(()))
                }
            return Disposables.create()
        }
    }
    
    public func deleteDocument(collection: FireStoreCollection, document: String) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.database.collection(collection.name)
                .document(document)
                .delete { error in
                    if let error = error { single(.failure(error)) }
                    single(.success(()))
                }
            return Disposables.create()
        }
    }
    
    public func deleteDocuments(collections: [(FireStoreCollection, String)]) -> Single<Void> {
        let batch = self.database.batch()
        
        collections.forEach { collection, document in
            let document = self.database.collection(collection.name).document(document)
            batch.deleteDocument(document)
        }
        
        return Single.create { single in
            batch.commit { error in
                if let error = error { single(.failure(error)) }
                single(.success(()))
            }
            
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
    
    func setAccessLevel(_ level: AccessLevel) -> Single<Void> {
        return self.getCurrentUser()
            .flatMap({ user -> Single<Void> in
                return self.updateDocument(collection: .Users, document: user.uid, values: ["accessLevel": level.toString])
            })
    }
    
}

//MARK: ImageUpload
extension DefaultFirebaseService {
    public func uploadImage(filePath: String, image: UIImage) -> Single<String> {
        return Single.create { single in
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { return Disposables.create() }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imageName = filePath
            let firebaseReference = Storage.storage().reference().child("\(imageName)")
            
            firebaseReference.putData(imageData, metadata: metaData) { _, error in
                if let error = error { single(.failure(error)) }
                
                firebaseReference.downloadURL { url, _ in
                    guard let url = url else {
                        single(.failure(FireStoreError.unknown))
                        return
                    }
                    let cachedKey = NSString(string: url.absoluteString)
                    ImageCacheManager.shared.setObject(UIImage(data: imageData)!, forKey: cachedKey)
                    single(.success(url.absoluteString))
                }
            }
            return Disposables.create()
        }
    }
    
    public func downloadImage(urlString: String) -> Single<UIImage?> {
        return Single.create { single in
            guard !urlString.isEmpty else {
                single(.success(nil))
                return Disposables.create()
            }
            let cachedKey = NSString(string: urlString)
            
            if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                single(.success(cachedImage))
                return Disposables.create()
            }
            
            let storageReference = Storage.storage().reference(forURL: urlString)
            let megaByte = Int64(1 * 1024 * 1024)
            
            storageReference.getData(maxSize: megaByte) { data, error in
                guard let imageData = data else {
                    single(.success(nil))
                    return
                }
                ImageCacheManager.shared.setObject(UIImage(data: imageData)!, forKey: cachedKey)
                single(.success(UIImage(data: imageData)))
            }
            return Disposables.create()
        }
    }
    
    public func deleteImageFromProfileStorage(imageURL: String) -> Single<Void> {
        return Single.create { single in
            let storage = Storage.storage()
            let storageReference = storage.reference(forURL: imageURL)
            let cachedKey = NSString(string: imageURL)
            storageReference.delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                    ImageCacheManager.shared.removeObject(forKey: cachedKey)
                }
            }
            return Disposables.create()
        }
        
    }
    
    public func deleteImageFromChatStorage(filePath: [String]) -> Single<Void> {
        return Single.create { single in
            guard !filePath.isEmpty else{
                single(.success(()))
                return Disposables.create()
            }
            var resultCount = 0

            for path in filePath {
                self.deleteImageFromProfileStorage(imageURL: path)
                    .subscribe(onSuccess: { _ in
                        resultCount += 1
                        if resultCount == filePath.count {
                            single(.success(()))
                            return
                        }
                    }, onFailure: { error in
                        single(.failure(error))
                        return
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }

    }
    
}
