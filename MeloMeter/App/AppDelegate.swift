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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        // 네이버 지도 초기화
        NMFAuthManager.shared().clientId = "qf06vqg44t"
        //KakaoSDK
        KakaoSDK.initSDK(appKey: "63ff1c816c3c2dd940969416c8e2ce35")
        // 파이어베이스 연동, 알림설정
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        Messaging.messaging().isAutoInitEnabled = true
        
        // device token 요청.
        application.registerForRemoteNotifications()
        
        // Request permission for remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        if (launchOptions?[.remoteNotification]) != nil {
            //여기서 처리
        }

        
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
        
        //사일런트 푸시 받는 용도
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
    
    // 푸시클릭시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("🟢 클릭 : ", #function)
    }
    

    // 앱화면 보고있는중에 푸시올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        let date = Date().toString(type: .yearToDay)
        let text = notification.request.content.body
        if let type = userInfo["type"] { PushNotificationService.shared.addAlarm(text: text, date: date, type: type as! String )
        }

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
