//
//  HundredQAUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation
import RxSwift
import RxRelay
import GoogleMobileAds
public class HundredQAUseCase {
    
    private var disposeBag: DisposeBag
    private var hundredQARepository: HundredQARepositoryP
    private var admobRepo: AdmobRepositoryP
    
    public init(hundredQARepository: HundredQARepositoryP, admobRepo: AdmobRepositoryP) {
        self.hundredQARepository = hundredQARepository
        self.disposeBag = DisposeBag()
        self.admobRepo = admobRepo
    }
    
    public func getAnswerList() -> Single<[AnswerInfoModel]> {
        return Single.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            
            self.hundredQARepository.getCoupleID().subscribe(onSuccess: { coupleID in
                self.hundredQARepository.getAnswerList(coupleID: coupleID)
                    .subscribe(onSuccess: { list in
                        single(.success(list))
                    },onFailure: { error in
                        single(.failure(error))
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    
    }
 
    public func addAnswer(questionNumber: String, answerInfo: AnswerModel) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.hundredQARepository.getCoupleID().subscribe(onSuccess: { coupleID in
                self.hundredQARepository.setAnswerList(questionNumber: questionNumber, answerData: answerInfo, coupleID: coupleID)
                    .subscribe(onSuccess: {
                        single(.success(()))
                    })
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)

            return Disposables.create()
        }
    }
    
    public func addQuestion(newQuestion: Int) {
        self.hundredQARepository.getCoupleID().subscribe(onSuccess: { coupleID in
            self.hundredQARepository.setAnswerList(questionNumber: String(newQuestion), answerData: nil, coupleID: coupleID)
                .subscribe(onSuccess: {
                    print("성공")
                })
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

    }
}

extension HundredQAUseCase {
    public func loadInterstitial() -> Single<InterstitialAd> {
        return admobRepo.loadInterstitial()
    }
    
}
