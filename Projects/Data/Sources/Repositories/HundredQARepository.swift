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
import Domain

public class HundredQARepository: HundredQARepositoryP {
    
    public var firebaseService: FirebaseService
    public var disposeBag: DisposeBag
    public var coupleModel: PublishSubject<CoupleModel?>
    
    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.coupleModel = PublishSubject()
        self.disposeBag = DisposeBag()
    }
    
    public func getCoupleID() -> Single<String> {
        if let coupleID = UserDefaults.standard.string(forKey: "coupleID") {
            return Single.just(coupleID)
        }else {
            return self.firebaseService.getCurrentUser()
                .flatMap{ user -> Single<String> in
                    return self.firebaseService.getDocument(collection: .Users, document: user.uid)
                        .flatMap{ data -> Single<String> in
                            guard let id = data["coupleID"] as? String else{ return Single.just("") }
                            UserDefaults.standard.set(id, forKey: "coupleID")
                            return Single.just(id)
                        }
                        
                }
        }
    }
    
    public func getAnswerList(coupleID: String) -> Single<[AnswerInfoModel]> {
        return self.firebaseService.getDocument(collection: .Couples, document: coupleID)
            .flatMap { documentSnapshot -> Single<[AnswerInfoModel]> in
                
                if let answersList = documentSnapshot["answersList"] as? [String: Any], !answersList.isEmpty{

                    return self.getQusestionList()
                        .flatMap { questionList -> Single<[AnswerInfoModel]> in

                            var resultDTO: [AnswerInfoDTO] = []
                            for questionNumber in 0...answersList.count {
                                var answerDTOArray: [AnswerDTO] = []
                                var date = ""
                                for answerInfo in answersList[String(questionNumber)] as? [[String: String]] ?? [] {
                                    if let dateValue = answerInfo["date"] {
                                        date = dateValue
                                        continue
                                    }
                                    let answerDTO = AnswerDTO(
                                        userId: answerInfo["userId"] ?? "",
                                        answerText: answerInfo["answerText"] ?? "",
                                        userName: answerInfo["userName"] ?? ""
                                    )
                                    
                                    answerDTOArray.append(answerDTO)
                                }
                                
                                let answerInfoDTO = AnswerInfoDTO(
                                    answerInfo: answerDTOArray,
                                    questionText: questionList[Int(questionNumber)],
                                    date: date
                                )
                                resultDTO.append(answerInfoDTO)
                            }
                            let resultModel = resultDTO.map { $0.toModel() }
                            return Single.just(resultModel)
                        }
                } else {
                    return self.getQusestionList()
                        .flatMap { questionList -> Single<[AnswerInfoModel]> in
                            let answerInfoDTO = AnswerInfoDTO(
                                answerInfo: [AnswerDTO(userId: "", answerText: "", userName: "")],
                                questionText: questionList[0],
                                date: ""
                            )
                            return Single.just([answerInfoDTO.toModel()])
                        }
                    
                }

            }
    }
    
    public func getQusestionList() -> Single<[String]> {
        return self.firebaseService.getDocument(collection: .QusestionList, document: "IRzqEbKybgdvUij8LZpT")
            .map{ listDic in
                guard let listArray = listDic["List"] as? [String] else{ return []}
                return listArray
            }
    }

    public func setAnswerList(questionNumber: String, answerData: AnswerModel?, coupleID: String) -> Single<Void> {
        if let answerData = answerData {
            guard let values = answerData.toDTO().asDictionary else{ return Single.just(())}
            return self.firebaseService.createDocument(
                collection: .Couples,
                document: coupleID,
                values: ["answersList" :  [questionNumber: FieldValue.arrayUnion([values])] ]
            )
            .flatMap{ _ in
                let userName = UserDefaults.standard.string(forKey: "name") ?? "상대방"
                PushNotificationService.shared.sendPushNotification(title: "MeloMeter", body: "\(userName)님이 \((Int(questionNumber) ?? 0)+1)번째 백문백답에 답변했어요!", type: AlarmType.hundredQA)
                return Single.create{ single in
                    single(.success(()))
                    return Disposables.create()
                }
            }
        }else {
            let currentDate = Date().toString(type: .yearToHour)
            let values: [Any] = [["date": currentDate]]
            return self.firebaseService.createDocument(
                collection: .Couples,
                document: coupleID,
                values: ["answersList" :  [questionNumber: FieldValue.arrayUnion(values)] ]
            )
            .flatMap{ _ in
                PushNotificationService.shared.sendPushNotification(title: "MeloMeter", body: "오늘의 질문이 도착했어요!", type: AlarmType.defaultValue)
                PushNotificationService.shared.localPushNotification(title: "MeloMeter", body: "오늘의 질문이 도착했어요!")
                return Single.create{ single in
                    single(.success(()))
                    return Disposables.create()
                }
            }
        }
    }
    
    
    public func answerListObserver() {
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
