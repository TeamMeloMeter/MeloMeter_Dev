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
    case auth, withdraw, connection, backup
    
    var detailData: [QnADataType: [String]] {
        switch self {
        case .auth:
            return [.title: ["계정 인증이 뭔가요?",
                             "여러 개의 아이디를 만들 수 있나요?"],
                    .contents: ["""
                                상대와 연결하기 위해 휴대폰 번호(아이디) 인증을
                                뜻합니다. 아이디는 원활한 앱 사용을 위해 필수 인증
                                절차입니다.
                                """,
                               """
                               본인의 휴대폰 번호로 인증 후 가입하기 때문에
                               여러 개의 아이디를 만들 수 없습니다.
                               """
                               ]]
        case .withdraw:
            return [.title: ["탈퇴 절차를 알려주세요"],
                    .contents: ["""
                                탈퇴 절차를 안내드립니다.
                                마이페이지 > 프로필 편집 > 탈퇴
                                
                                탈퇴 시 상대방과의 연결이 끊기니 신중하게
                                결정해 주세요!
                                """]]
        case .connection:
            return [.title: ["""
                    연결이 끊긴 상대방과 다시 연결하려면
                    어떻게 해야하나요?
                    """],
                    .contents: ["""
                                연결이 끊긴지 30일 이내라면
                                ‘자료 복구 신청하기’ 를 통해
                                재연결과 연결 정보 복구가 가능합니다.
                                """]]
        case .backup:
            return [.title: ["자료를 복구하고 싶을 때 어떻게 해야하나요?"],
                    .contents: ["""
                                연결이 끊긴지 30일 이내라면
                                ‘자료 복구 신청하기’ 를 통해
                                재연결과 연결 정보 복구가 가능합니다.

                                연결이 끊긴지 30일이 경과했다면
                                데이터가 완전히 파기되므로,
                                복구 및 재연결이 불가능합니다.

                                동일한 계정으로 재가입한 경우에도 복구가 불가능 하니,
                                신중하게 결정해 주세요!
                                """]]

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
        var titleStringData = BehaviorRelay<[String]>(value: QnARadioBtn.auth.detailData[.title]!)
    }
    
    init(coordinator: MyProfileCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillApearEvent
            .subscribe(onNext: { _ in
                //output.titleStringData.accept(QnARadioBtn.auth.detailData[.title]!)
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



