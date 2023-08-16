//
//  NoticeVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/14.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class NoticeVM {

    weak var coordinator: MyProfileCoordinator?

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let cellTapEvent: Observable<Int>
    }
    
    struct DetailInput {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var selectedContents = PublishSubject<[String: String]>()
    }
    
    init(coordinator: MyProfileCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
//        input.viewWillApearEvent
//            .subscribe(onNext: {[weak self] _ in
//                guard let self = self else{ return }
//               
//            })
//            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.cellTapEvent
            .subscribe(onNext: {[weak self] index in
                guard let self = self else{ return }
                self.coordinator?.showDetailNoticeVC()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func detailTransform(input: DetailInput, disposeBag: DisposeBag) {
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
    }
    
}
