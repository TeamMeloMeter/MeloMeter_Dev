//
//  QnAVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/15.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

enum QnADataType {
    case title, contents
}

enum QnARadioBtn {
    case auth, withdraw, location, connection, backup, etc
    
    var detailData: [QnADataType: [String]] {
        switch self {
        case .auth:
            return [.title: ["가입/인증에 대해"],
                    .contents: ["가입설명"]]
        case .withdraw:
            return [.title: ["변경/탈퇴에 대해"],
                    .contents: ["탈퇴설명"]]
        case .location:
            return [.title: ["위치기반에 대해"],
                    .contents: ["위치기반설명"]]
        case .connection:
            return [.title: ["연결/재연결에 대해"],
                    .contents: ["연결 설명"]]
        case .backup:
            return [.title: ["백업/복구에 대해"],
                    .contents: ["백업 설명"]]
        case .etc:
            return [.title: ["그외 에 대해"],
                    .contents: ["기타 설명"]]
        }
    }
    
}

class QnAVM {

    weak var coordinator: MyProfileCoordinator?
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let radioBtnTapEvent: Observable<QnARadioBtn>
        let cellTapEvent: Observable<(QnARadioBtn, Int)>
    }
    
    struct DetailInput {
        let backBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var titleStringData = PublishRelay<[String]>()
    }
    
    init(coordinator: MyProfileCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: { _ in
                output.titleStringData.accept(QnARadioBtn.auth.detailData[.title]!)
            })
            .disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.radioBtnTapEvent
            .subscribe(onNext: { select in
                output.titleStringData.accept(select.detailData[.title]!)
            })
            .disposed(by: disposeBag)
        
        input.cellTapEvent
            .subscribe(onNext: {[weak self] btnType, index in
                guard let self = self else{ return }
                let title = btnType.detailData[.title]![index]
                let contents = btnType.detailData[.contents]![index]
                self.coordinator?.showDetailQnAVC(title: title, contents: contents)
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



