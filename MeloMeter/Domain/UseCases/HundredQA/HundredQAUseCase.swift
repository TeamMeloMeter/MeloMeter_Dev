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
    private var coupleRepository: CoupleRepository
    
    init(coupleRepository: CoupleRepository) {
        self.coupleRepository = coupleRepository
        self.disposeBag = DisposeBag()
    }
 
    
}
