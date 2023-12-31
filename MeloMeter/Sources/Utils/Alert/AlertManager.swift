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
    
    func setTitle(_ title: String) -> AlertManager {
        alertTitle = title
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
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.modalTransitionStyle = .crossDissolve

        alertViewController.alertTitle = alertTitle
        alertViewController.message = message
        alertViewController.addActionConfirm = addActionConfirm
        baseViewController.tabBarController?.tabBar.isUserInteractionEnabled = false
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
    
    func showYNAlert() -> Single<Void> {
        
        return Single.create{ single in
            let alertController = UIAlertController(title: self.alertTitle, message: self.message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: self.alertTitle, style: .destructive) { _ in
                single(.success(()))
            }
            let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.baseViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
 
    func showRequestLocationServiceAlert() -> Single<Bool> {
        return Single.create { single in
            let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
            let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
                single(.success(true))
            }
            requestLocationServiceAlert.addAction(goSetting)
            
            self.baseViewController.present(requestLocationServiceAlert, animated: true)
            return Disposables.create {
                requestLocationServiceAlert.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    func setLocationAlert() {
        let authAlertController: UIAlertController
        authAlertController = UIAlertController(
            title: "위치정보 권한 요청",
            message: """
                    상대방과의 위치공유를 위해서 위치정보 권한을
                    '항상 허용'으로 설정해주세요!
                    앱을 사용하지 않을 때에도
                    위치 정보가 수집됩니다.
                    """,
            preferredStyle: .alert
        )
        
        let getAuthAction: UIAlertAction
        getAuthAction = UIAlertAction(
            title: "항상 허용 설정하기",
            style: .default,
            handler: { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        )
        
        authAlertController.addAction(getAuthAction)
        self.baseViewController.present(authAlertController, animated: true, completion: nil)
    }
    
    func showGenderAlert() -> Single<GenderType> {
        return Single.create { single in
            let alertController = UIAlertController(title: "성별", message: nil, preferredStyle: .actionSheet)
            let male = UIAlertAction(title: "남성", style: .default) { action in
                single(.success(.male))
            }
            let female = UIAlertAction(title: "여성", style: .default) { action in
                single(.success(.female))
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(male)
            alertController.addAction(female)
            alertController.addAction(cancel)
            self.baseViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showCameraAlert() -> Single<CameraAlert> {
        return Single.create { single in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let take = UIAlertAction(title: "사진찍기", style: .default) { action in
                single(.success(.take))
            }
            let get = UIAlertAction(title: "앨범에서 선택하기", style: .default) { action in
                single(.success(.get))
            }
            let delete = UIAlertAction(title: "프로필 사진 지우기", style: .destructive) { action in
                single(.success(.delete))
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(take)
            alertController.addAction(get)
            alertController.addAction(delete)
            alertController.addAction(cancel)
        
            self.baseViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: Chat Alert
extension AlertManager {
    static func showAlert(
        style: UIAlertController.Style,
        title: String?,
        message: String?,
        actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)],
        completion: (() -> Swift.Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        
        self.getTopViewController()?.present(alert, animated: true, completion: completion)
    }
    static func getTopViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}
