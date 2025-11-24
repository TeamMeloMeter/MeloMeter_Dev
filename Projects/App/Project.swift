import ProjectDescription

let project = Project(
  name: "MeloMeter",
  organizationName: "com.teamMeloMeter",
  packages: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
    .package(url: "https://github.com/luximetr/AnyFormatKit.git", .upToNextMajor(from: "2.5.2")),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.22.1")),
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
  ],
  targets: [
    // MARK: - Main App
    .target(
      name: "MeloMeter",
      destinations: .iOS,
      product: .app,
      bundleId: "com.teamMeloMeter.-",
      deploymentTargets: .iOS("16.0"),
      infoPlist: .file(path: "../../MeloMeter/Info.plist"),
      sources: [
        "../../MeloMeter/Sources/**",
        "../../MeloMeter/FirebaseService/**",
        "../../MeloMeter/ProfileInput/**",
        "../../MeloMeter/Views/**",
        "../../KakaoService/**",
        "../../LocationService/**"
      ],
      resources: [
        "../../MeloMeter/Resources/**",
        "../../MeloMeter/Resources/LaunchScreen/Base.lproj/LaunchScreen.storyboard",
        "../../MeloMeter/**/.xcassets",
        "../../MeloMeter/**/Base.lproj/**",
        "../../MeloMeter/**/ko.lproj/**",
        "../../MeloMeter/GoogleService-Info.plist"
      ],
      dependencies: [
        // Firebase
        .package(product: "FirebaseAnalytics"),
        .package(product: "FirebaseAuth"),
        .package(product: "FirebaseCrashlytics"),
        .package(product: "FirebaseAppCheck"),
        .package(product: "FirebaseDatabase"),
        .package(product: "FirebaseFirestore"),
        .package(product: "FirebaseFirestoreSwift"),
        .package(product: "FirebaseMessaging"),
        .package(product: "FirebaseRemoteConfig"),
        .package(product: "FirebaseStorage"),

        // Google Ads
        .package(product: "GoogleMobileAds"),
        .package(product: "GoogleUserMessagingPlatform"),

        // Kakao SDK
        .package(product: "KakaoSDK"),
        .package(product: "KakaoSDKCommon"),
        .package(product: "KakaoSDKAuth"),
        .package(product: "KakaoSDKUser"),
        .package(product: "KakaoSDKShare"),
        .package(product: "KakaoSDKTemplate"),
        .package(product: "KakaoSDKCert"),

        // Utility & UI
        .package(product: "Alamofire"),
        .package(product: "Kingfisher"),
        .package(product: "SnapKit"),
        .package(product: "AnyFormatKit"),
        .package(product: "MessageKit"),
        .package(product: "NMapsMap"),
        .package(product: "Then"),

        // Rx
        .package(product: "RxSwift"),
        .package(product: "RxCocoa"),
        .package(product: "RxGesture")
      ]
    ),

    // MARK: - Tests
    .target(
      name: "MeloMeterTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "com.teamMeloMeter.tests",
      infoPlist: .default,
      sources: [
        "../../MeloMeterTests/**"
      ],
      dependencies: [
        .target(name: "MeloMeter")
      ]
    ),

    // MARK: - Widget
    .target(
      name: "MelometerWidget",
      destinations: .iOS,
      product: .appExtension,
      bundleId: "com.teamMeloMeter.-.MelometerWidget",
      infoPlist: .file(path: "../../MelometerWidget/Info.plist"),
      sources: [
        "../../MelometerWidget/**"
      ],
      resources: [
        "../../MelometerWidget/Assets.xcassets",
        "../../MelometerWidget/Font/**"
      ],
      dependencies: []
    )
  ]
)
