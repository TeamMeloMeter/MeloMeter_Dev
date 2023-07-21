//
//  Alert.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/13.
//

import UIKit
import RxSwift

struct AddAction {
  var text: String?
  var action: (() -> Void)?
}
// MARK: - Alert 싱글톤 클래스
class AlertManager {
    private let baseViewController: UIViewController
    private let alertViewController = CustomAlertVC()
    private var alertTitle: String?
    private var message: String?
    private var addActionConfirm: AddAction?
    
    init(viewController: UIViewController) {
        baseViewController = viewController
    }
    
    func setTitle(_ time: String) -> AlertManager {
        alertTitle = time
        return self
    }
    
    func setMessage(_ text: String) -> AlertManager {
        message = text
        return self
    }
    
    func addActionConfirm(_ text: String, action: (() -> Void)? = nil) -> AlertManager {
        addActionConfirm = AddAction(text: text, action: action)
        return self
    }
    
    @discardableResult
    func showCustomAlert() -> Self {
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.modalTransitionStyle = .crossDissolve
        
        alertViewController.alertTitle = alertTitle
        alertViewController.message = message
        alertViewController.addActionConfirm = addActionConfirm
        
        baseViewController.present(alertViewController, animated: true)
        return self
    }
    
    func showNomalAlert(title: String, message: String) -> Single<Void> {
        return Single.create { single in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(()))
            }
            alertController.addAction(okAction)
            self.baseViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
