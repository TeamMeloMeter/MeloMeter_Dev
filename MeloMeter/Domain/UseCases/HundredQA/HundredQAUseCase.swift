//
//  HundredQAUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxRelay

class HundredQAUserCase {
    
    private var disposeBag: DisposeBag
    private var hundredQARepository: HundredQARepository
    
    init(hundredQARepository: HundredQARepository) {
        self.hundredQARepository = hundredQARepository
        self.disposeBag = DisposeBag()
    }
 
    func addAnswer(answerText: String) {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        self.hundredQARepository.getAnswerList()
    }
    
}
