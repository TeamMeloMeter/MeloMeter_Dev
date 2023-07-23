//
//  KeyboardStatusDetector.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/20.
//

import UIKit
import RxSwift
import RxCocoa

class KeyboardStatusDetector {
    let disposeBag = DisposeBag()
    let keyboardStatusSubject = PublishSubject<[Any]>()

    init() {
        // 키보드 알림 등록
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { notification in
                let kb_height = self.findHeight(notification)
                self.keyboardStatusSubject.onNext([true,kb_height])
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { notification in
                let kb_height = self.findHeight(notification)
                self.keyboardStatusSubject.onNext([false,kb_height])
            })
            .disposed(by: disposeBag)
    }
    
    func findHeight(_ notification : Notification) -> CGFloat{
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary;
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue;
        let keyboardHeight = keyboardRectangle.size.height;
        
        return keyboardHeight
    }
}


