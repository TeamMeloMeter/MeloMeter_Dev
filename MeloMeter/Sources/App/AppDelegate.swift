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
import UserNotifications
import FirebaseAppCheck
import KakaoSDKCommon
import GoogleMobileAds
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaultsRepo.shared.resetAllUserDefaults()
        // 구글 애드모
        MobileAds.shared.start(completionHandler: nil)
        
        // Override point for customization after application launch.
        // 네이버 지도 초기화
        NMFAuthManager.shared().clientId = "qf06vqg44t"
        //KakaoSDK
        KakaoSDK.initSDK(appKey: "63ff1c816c3c2dd940969416c8e2ce35")
        // 파이어베이스 연동, 알림설정
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        // device token 요청.
        application.registerForRemoteNotifications()
        
        PushNotificationService.shared.registerForPushNotifications()
        // Request permission for remote notifications
        UNUserNotificationCenter.current().delegate = self
        
      
        
        if (launchOptions?[.remoteNotification]) != nil {
            //여기서 처리
        }
        
        if launchOptions?[.location] != nil {
            PushNotificationService.shared.localPushNotification(title: "위치 업데이트", body: "위치 업데이트 성공!")
           }

    
        // 위치 관련 addObserver 활성화
        PushNotificationService.shared.setupAppStateNotifications()
        
        return true
    }
    
    // FCMToken 업데이트시
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🟢 fcmToken : ", #function, fcmToken ?? "")
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
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
    
    // 푸시클릭이벤트
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
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
