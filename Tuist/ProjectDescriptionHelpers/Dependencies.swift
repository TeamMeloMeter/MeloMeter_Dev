import ProjectDescription

public enum ProjectPackages {
  public static let all: [Package] = [
    .package(path: "../../Packages/abseil-cpp-binary"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
    .package(url: "https://github.com/luximetr/AnyFormatKit.git", .upToNextMajor(from: "2.5.2")),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("10.28.0")),
    .package(url: "https://github.com/kakao/kakao-ios-sdk.git", .upToNextMajor(from: "2.25.0")),
    .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.6.1")),
    .package(url: "https://github.com/MessageKit/MessageKit.git", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", .upToNextMajor(from: "4.0.4")),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.9.1")),
    .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
    .package(url: "https://github.com/navermaps/SPM-NMapsMap.git", .upToNextMajor(from: "3.23.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.12.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", .upToNextMajor(from: "3.1.0")),
    .package(url: "https://github.com/devxoul/Then.git", .upToNextMajor(from: "3.0.0"))
  ]
}

public enum ExternalDependencies {
  public static let alamofire = TargetDependency.package(product: "Alamofire")
  public static let anyFormatKit = TargetDependency.package(product: "AnyFormatKit")

  public static let firebaseAnalytics = TargetDependency.package(product: "FirebaseAnalytics")
  public static let firebaseAuth = TargetDependency.package(product: "FirebaseAuth")
  public static let firebaseCrashlytics = TargetDependency.package(product: "FirebaseCrashlytics")
  public static let firebaseAppCheck = TargetDependency.package(product: "FirebaseAppCheck")
  public static let firebaseDatabase = TargetDependency.package(product: "FirebaseDatabase")
  public static let firebaseFirestore = TargetDependency.package(product: "FirebaseFirestore")
  public static let firebaseFirestoreSwift = TargetDependency.package(product: "FirebaseFirestoreSwift")
  public static let firebaseMessaging = TargetDependency.package(product: "FirebaseMessaging")
  public static let firebaseRemoteConfig = TargetDependency.package(product: "FirebaseRemoteConfig")
  public static let firebaseStorage = TargetDependency.package(product: "FirebaseStorage")

  public static let kakaoSDK = TargetDependency.package(product: "KakaoSDK")
  public static let kakaoSDKCommon = TargetDependency.package(product: "KakaoSDKCommon")
  public static let kakaoSDKAuth = TargetDependency.package(product: "KakaoSDKAuth")
  public static let kakaoSDKUser = TargetDependency.package(product: "KakaoSDKUser")
  public static let kakaoSDKShare = TargetDependency.package(product: "KakaoSDKShare")
  public static let kakaoSDKTemplate = TargetDependency.package(product: "KakaoSDKTemplate")
  public static let kakaoSDKCert = TargetDependency.package(product: "KakaoSDKCert")
  public static let kakaoSDKTalk = TargetDependency.package(product: "KakaoSDKTalk")

  public static let kingfisher = TargetDependency.package(product: "Kingfisher")
  public static let messageKit = TargetDependency.package(product: "MessageKit")

  public static let rxGesture = TargetDependency.package(product: "RxGesture")
  public static let rxSwift = TargetDependency.package(product: "RxSwift")
  public static let rxCocoa = TargetDependency.package(product: "RxCocoa")
  public static let rxRelay = TargetDependency.package(product: "RxRelay")

  public static let snapKit = TargetDependency.package(product: "SnapKit")
  public static let nMapsMap = TargetDependency.package(product: "NMapsMap")
  public static let googleMobileAds = TargetDependency.package(product: "GoogleMobileAds")
  public static let googleUserMessagingPlatform = TargetDependency.package(product: "GoogleUserMessagingPlatform")
  public static let then = TargetDependency.package(product: "Then")
}
