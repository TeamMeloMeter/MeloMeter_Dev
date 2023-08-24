//
//  HundredQARepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

class HundredQARepository: HundredQARepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    var coupleModel: PublishSubject<CoupleModel?>
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.coupleModel = PublishSubject()
        self.disposeBag = DisposeBag()
    }
    
    func getCoupleID() -> Single<String> {
        if let coupleID = UserDefaults.standard.string(forKey: "coupleDocumentID") {
            return Single.just(coupleID)
        }else {
            return self.firebaseService.getCurrentUser()
                .flatMap{ user -> Single<String> in
                    return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .flatMap{ data -> Single<String> in
                            guard let id = data["coupleID"] as? String else{ return Single.just("") }
                            UserDefaults.standard.set(id, forKey: "coupleDocumentID")
                            return Single.just(id)
                        }
                        
                }
        }
    }
    
    func getAnswerList(coupleID: String) -> Single<[AnswerInfoDTO]> {
        return self.firebaseService.getDocument(collection: .Couples, document: coupleID)
            .flatMap { documentSnapshot -> Single<[AnswerInfoDTO]> in
                
                if let answersList = documentSnapshot["answersList"] as? [String: Any], !answersList.isEmpty{

                    return self.getQusestionList()
                        .flatMap { questionList -> Single<[AnswerInfoDTO]> in

                            var resultDTO: [AnswerInfoDTO] = []
                            for questionNumber in answersList.keys.sorted(by: { Int($0) ?? 0 < Int($1) ?? 0 }) {
                                var answerDTOArray: [AnswerDTO] = []
                                for answerInfo in answersList[questionNumber] as? [[String: String]] ?? [] {
                                    
                                    let answerDTO = AnswerDTO(
                                        userId: answerInfo["userId"] ?? "",
                                        answerText: answerInfo["answerText"] ?? "",
                                        userName: answerInfo["userName"] ?? ""
                                    )
                                    
                                    answerDTOArray.append(answerDTO)
                                }

                                let answerInfoDTO = AnswerInfoDTO(
                                    answerInfo: answerDTOArray,
                                    questionText: questionList[Int(questionNumber) ?? 0]
                                )
                                resultDTO.append(answerInfoDTO)
                            }
                            return Single.just(resultDTO)
                        }
                } else {
                    return self.getQusestionList()
                        .flatMap { questionList in
                            let answerInfoDTO = AnswerInfoDTO(
                                answerInfo: [AnswerDTO(userId: "", answerText: "", userName: "")],
                                questionText: questionList[0]
                            )
                            return Single.just([answerInfoDTO])
                        }
                    
                }

            }
    }
    
    func getQusestionList() -> Single<[String]> {
        return self.firebaseService.getDocument(collection: .QusestionList, document: "IRzqEbKybgdvUij8LZpT")
            .map{ listDic in
                guard let listArray = listDic["List"] as? [String] else{ return []}
                return listArray
            }
    }

    func setAnswerList(questionNumber: String, answerData: AnswerModel, coupleID: String) -> Single<Void> {
        guard let values = answerData.toDTO().asDictionary else{ return Single.just(())}
        print("리포지토리 입력정보", answerData)
        return self.firebaseService.createDocument(
            collection: .Couples,
            document: coupleID,
            values: ["answersList" :  [questionNumber: FieldValue.arrayUnion([values])] ]
        )

    }
    
    
    func answerListObserver() {
        getCoupleID()
            .subscribe(onSuccess: { coupleID in
                self.firebaseService.observer(collection: .Couples, document: coupleID)
                    .map{ $0.toObject(CoupleDTO.self)?.toModel() ?? CoupleModel(firstDay: Date(), anniversaries: []) }
                    .asObservable()
                    .bind(to: self.coupleModel)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
    
}
