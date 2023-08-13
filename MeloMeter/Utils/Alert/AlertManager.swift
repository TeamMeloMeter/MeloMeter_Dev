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
    
    func showRequestLocationServiceAlert() -> Single<Bool> {
        return Single.create { single in
            let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
            let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
                single(.success(true))
            }
//            let cancel = UIAlertAction(title: "허용 안함", style: .default) {_ in
//                single(.success(false))
//            }
            //requestLocationServiceAlert.addAction(cancel)
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
