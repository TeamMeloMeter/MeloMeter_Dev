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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        // 네이버 지도 초기화
        NMFAuthManager.shared().clientId = "qf06vqg44t"
        //KakaoSDK
        KakaoSDK.initSDK(appKey: "63ff1c816c3c2dd940969416c8e2ce35")
        // 파이어베이스 연동, 알림설정
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()

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
    
    // 푸시클릭시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("🟢 클릭 : ", #function)
        let userInfo = response.notification.request.content.userInfo
        
            
    }

    // 앱화면 보고있는중에 푸시올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("🟢 인앱 : ", #function)
        
        return [.sound, .banner, .list]
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
