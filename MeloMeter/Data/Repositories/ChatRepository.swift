//
//  ChatRepository.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

class ChatRepository: ChatRepositoryP{
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    // MockMessage타입을 인자로 받아서 fireBase에 insert하는 함수 / 리턴 t/f
    func addChatMessage(mockMessage: MockMessage) -> Single<Void> {
        let myCoupleid = UserDefaults.standard.string(forKey: "coupleDocumentID") ?? ""
        let dto = mockMessage.toDTO()
        let values = dto.asDictionary ?? [:]
        let valArr = [values]
        print(myCoupleid," #############")
        return self.firebaseService.updateDocument(collection: .Chat, document: myCoupleid, values: ["chatField":valArr])
        
//        return Single<Void>.create { single in
//            let myUid = UserDefaults.standard.string(forKey: "uid") ?? ""
//            let dto = mockMessage.toDTO()
//            let values = dto.asDictionary ?? [:]
//            let valArr = [values]
//
//            return self.firebaseService.getDocument(collection: .Chat, field: myUid, values: [])
//                .flatMap{ data -> Single<Void> in
//                    if data.isEmpty {
//                        return self.firebaseService.createDocument(collection: .Chat, document: myUid, values: ["chatFeild":valArr])
//                    }else{
//                        let pdata = data.append(contentsOf: valArr)
//                        return self.firebaseService.updateDocument(collection: .Chat, document: myUid, values: pdata)
//                    }
//
//
//                }
//                .subscribe(onSuccess: {
//
//                }, onFailure: { error in
//                    single(.failure(error))
//                })
//                .disposed(by: disposeBag) as! Disposable
//        }
    }
}

