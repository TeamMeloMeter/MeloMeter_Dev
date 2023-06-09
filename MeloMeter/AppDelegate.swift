//
//  AppDelegate.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/18.
//

import UIKit
import NMapsMap
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // 네이버 지도 초기화
    NMFAuthManager.shared().clientId = "qf06vqg44t"
    
    // 파이어베이스 연결
    FirebaseApp.configure()
    
    // FCM 등록
    Messaging.messaging().delegate = self
    Messaging.messaging().isAutoInitEnabled = true
    
    return true
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {}
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // APNS Device Token 받은 후 서버에 전송하거나, FCM Token과 연결할 수 있음
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // APNS 등록 실패 시 호출
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNS 등록 실패: \(error.localizedDescription)")
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

