//
//  HundredQARepositoryP.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation
import RxSwift

public protocol HundredQARepositoryP {
    func getCoupleID() -> Single<String>
    func getAnswerList(coupleID: String) -> Single<[AnswerInfoModel]>
    func getQusestionList() -> Single<[String]>
    func setAnswerList(questionNumber: String, answerData: AnswerModel?, coupleID: String) -> Single<Void>
    func answerListObserver()
}
