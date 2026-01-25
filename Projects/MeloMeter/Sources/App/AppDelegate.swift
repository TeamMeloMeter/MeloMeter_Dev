//
//  AppDelegate.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/18.
//

import UIKit
import NMapsMap
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseRemoteConfig
import UserNotifications
import KakaoSDKCommon
import GoogleMobileAds
import Data
import Domain
import Core
import RxSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    private lazy var firebaseService = DefaultFirebaseService()
    private let disposeBag = DisposeBag()
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        BLEProximityMonitor.shared.refreshSessionState()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 파이어베이스 연동, 알림설정 (필수 - 메인스레드)
        FirebaseApp.configure()
        
        // UI 설정 (필수 - 메인스레드)
        configureGlobalAppearance()
        
        // 동기 초기화로 복구 (스플래시 멈춤 해결 시도)
        // 네이버 지도 초기화
        NMFAuthManager.shared().clientId = "qf06vqg44t"
        
        // KakaoSDK
        KakaoSDK.initSDK(appKey: "63ff1c816c3c2dd940969416c8e2ce35")
        
        // 구글 애드모
        MobileAds.shared.start(completionHandler: nil)
        
        // BLE & Location
        self.configureBleRemoteConfig()
        BLEProximityMonitor.shared.start(coupleId: UserDefaults.standard.string(forKey: "coupleID"))
        
        LocationService.shared.configure(firebaseService: firebaseService)
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("🟢 fcmToken fetch failed: \(error)")
                return
            }
            self?.persistFcmToken(token)
        }
        
        // device token 요청.
        application.registerForRemoteNotifications()
        
        PushNotificationService.shared.registerForPushNotifications()
        // Request permission for remote notifications
        UNUserNotificationCenter.current().delegate = self
        
      
        
        if (launchOptions?[.remoteNotification]) != nil {
            //여기서 처리
        }
        
        if launchOptions?[.location] != nil {
            
        }
 
        
        return true
    }

    private func configureBleRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            "ble_service_uuid": BLEConfiguration.defaultServiceUUIDString as NSObject,
            "ble_characteristic_uuid": BLEConfiguration.defaultCharacteristicUUIDString as NSObject
        ])

        remoteConfig.fetchAndActivate { _, error in
            let serviceString = remoteConfig.configValue(forKey: "ble_service_uuid").stringValue
            let characteristicString = remoteConfig.configValue(forKey: "ble_characteristic_uuid").stringValue
            print("[Remote] fetched service(\(serviceString)) characteristic(\(characteristicString))")
            if BLEConfiguration.shared.updateServiceUUID(with: serviceString) {
                print("[Remote] service UUID updated")
            }
            if BLEConfiguration.shared.updateCharacteristicUUID(with: characteristicString) {
                print("[Remote] characteristic UUID updated")
            }
            if let error = error {
                print("[Remote] fetch error: \(error)")
            }
        }
    }

    private func configureGlobalAppearance() {
        if #available(iOS 15.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = .white
            navAppearance.shadowColor = .clear
            if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
                navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
                let backButtonAppearance = UIBarButtonItemAppearance()
                backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
                backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
                backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
                backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
                navAppearance.backButtonAppearance = backButtonAppearance
            }
            let navBar = UINavigationBar.appearance()
            navBar.standardAppearance = navAppearance
            navBar.scrollEdgeAppearance = navAppearance
            navBar.compactAppearance = navAppearance
            if #available(iOS 16.0, *) {
                navBar.compactScrollEdgeAppearance = navAppearance
            }
            navBar.isTranslucent = false
            if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
                navBar.backIndicatorImage = backImage
                navBar.backIndicatorTransitionMaskImage = backImage
            }
            navBar.tintColor = .gray1
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            tabAppearance.backgroundColor = .white
            tabAppearance.shadowColor = .clear
            let tabBar = UITabBar.appearance()
            tabBar.standardAppearance = tabAppearance
            tabBar.scrollEdgeAppearance = tabAppearance
            tabBar.isTranslucent = false

            let toolbarAppearance = UIToolbarAppearance()
            toolbarAppearance.configureWithOpaqueBackground()
            toolbarAppearance.backgroundColor = .white
            toolbarAppearance.shadowColor = .clear
            let toolbar = UIToolbar.appearance()
            toolbar.standardAppearance = toolbarAppearance
            toolbar.scrollEdgeAppearance = toolbarAppearance
            toolbar.compactAppearance = toolbarAppearance
            if #available(iOS 16.0, *) {
                toolbar.compactScrollEdgeAppearance = toolbarAppearance
            }
            toolbar.isTranslucent = false
        }

        let searchBar = UISearchBar.appearance()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = false
        searchBar.tintColor = .gray1

        let searchTextField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchTextField.backgroundColor = .gray5
        searchTextField.textColor = .gray1
    }
    
    // FCMToken 업데이트시
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🟢 fcmToken : ", #function, fcmToken ?? "")
        persistFcmToken(fcmToken)
    }
    
    // 스위즐링 NO시, APNs등록, 토큰값가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🟢 deviceTokenString : ", #function, deviceTokenString)
    }
    
    // APNS 등록 실패 시 호출
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🟢APNS 등록 실패: \(error.localizedDescription)")
    }
    
    //완전종료 알림 처리
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //silentPush
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//
//            print("🟢 백그라운드 : ", #function)
//
//            if let title = userInfo["title"] as? String,
//               let date = userInfo["date"] as? String,
//               let body = userInfo["body"] as? String {
//                print("보낸사람 : \(title)")
//                print("내용 : \(date)")
//                print("시간 : \(body)")
//
//                PushNotificationService.shared.addAlarm(title: title, body: body, date: date, type: AlarmType.custom.stringType)
//            }
//        }
        
     }

    private func persistFcmToken(_ token: String?) {
        guard let token, token.isEmpty == false else { return }
        UserDefaults.standard.set(token, forKey: "fcmToken")
        updateFcmTokenInFirestore(token)
    }

    private func updateFcmTokenInFirestore(_ token: String) {
        guard FirebaseApp.app() != nil,
              let uid = UserDefaults.standard.string(forKey: "uid"),
              uid.isEmpty == false else { return }
        firebaseService.updateDocument(collection: .Users, document: uid, values: ["fcmToken": token])
            .subscribe(onSuccess: {}, onFailure: { error in
                print("🟢 fcmToken update failed: \(error)")
            })
            .disposed(by: disposeBag)

        if let otherUid = UserDefaults.standard.string(forKey: "otherUid"),
           otherUid.isEmpty == false {
            firebaseService.updateDocument(collection: .Users, document: otherUid, values: ["otherFcmToken": token])
                .subscribe(onSuccess: {}, onFailure: { error in
                    print("🟢 otherFcmToken update failed: \(error)")
                })
                .disposed(by: disposeBag)
        }
    }
    
    // 푸시클릭이벤트
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let link = userInfo["link"] as? String,
                  let url = URL(string: link) {
                   DispatchQueue.main.async {
                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                   }
               }
        completionHandler()

    }
    

    

    // 인앱푸시이벤트
    // iOS 14 이하 또는 AppDelegate에서 확실히 동작하기 위해 수정
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        let date = Date().toString(type: .yearToDay)
        let text = notification.request.content.body
        if let type = userInfo["type"] {
            PushNotificationService.shared.addAlarm(text: text, date: date, type: type as! String)
        }

        completionHandler([.sound, .banner, .list])
    }

    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}
