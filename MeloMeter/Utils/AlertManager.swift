//
//  Alert.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/13.
//

import UIKit
import RxSwift

// MARK: - Alert 싱글톤 클래스
final class AlertManager {
    
    static let shared = AlertManager()
    
    private init() {} //
    
    //기본 Alert
    func showNomalAlert(title: String, message: String) -> Single<Void> {
        return Single.create { single in
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let topViewController = windowScene.windows.first?.rootViewController?.topmostViewController()
            else {
                return Disposables.create()
            }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(()))
            }
            alertController.addAction(okAction)
            topViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //커스텀뷰 Alert
    func showCustomAlert(title: String, message: String, customView: UIView, constraints: @escaping () -> Void) -> Single<Void> {
        return Single.create { single in
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let topViewController = windowScene.windows.first?.rootViewController?.topmostViewController()
            else {
                return Disposables.create()
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.view.addSubview(customView)
            constraints()
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(()))
            }
            alertController.addAction(okAction)
            topViewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    

    
}
extension UIViewController {
    func topmostViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topmostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topmostViewController() ?? self
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topmostViewController() ?? self
        }
        return self
    }
}
