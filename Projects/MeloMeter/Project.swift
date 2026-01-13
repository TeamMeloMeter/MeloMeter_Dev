import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "MeloMeter",
  organizationName: "com.teamMeloMeter",
  packages: ProjectPackages.all,
  targets: [
    // MARK: - Main App
    .target(
      name: "MeloMeter",
      destinations: .iOS,
      product: .app,
      bundleId: "com.teamMeloMeter.-",
      deploymentTargets: .iOS("16.0"),
      infoPlist: .file(path: "Supporting/Info.plist"),
      sources: [
        "Sources/**"
      ],
      resources: [
        "Resources/**"
      ],
      dependencies: [
        // Firebase
        ExternalDependencies.firebaseAnalytics,
        ExternalDependencies.firebaseAuth,
        ExternalDependencies.firebaseCrashlytics,
        ExternalDependencies.firebaseAppCheck,
        ExternalDependencies.firebaseDatabase,
        ExternalDependencies.firebaseFirestore,
        ExternalDependencies.firebaseFirestoreSwift,
        ExternalDependencies.firebaseMessaging,
        ExternalDependencies.firebaseRemoteConfig,
        ExternalDependencies.firebaseStorage,

        // Google Ads
        ExternalDependencies.googleMobileAds,
        ExternalDependencies.googleUserMessagingPlatform,

        // Kakao SDK
        ExternalDependencies.kakaoSDK,
        ExternalDependencies.kakaoSDKCommon,
        ExternalDependencies.kakaoSDKAuth,
        ExternalDependencies.kakaoSDKUser,
        ExternalDependencies.kakaoSDKShare,
        ExternalDependencies.kakaoSDKTemplate,
        ExternalDependencies.kakaoSDKCert,
        ExternalDependencies.kakaoSDKTalk,

        // Utility & UI
        ExternalDependencies.alamofire,
        ExternalDependencies.kingfisher,
        ExternalDependencies.snapKit,
        ExternalDependencies.anyFormatKit,
        ExternalDependencies.messageKit,
        ExternalDependencies.nMapsMap,
        ExternalDependencies.then,

        // Rx
        ExternalDependencies.rxSwift,
        ExternalDependencies.rxCocoa,
        ExternalDependencies.rxRelay,
        ExternalDependencies.rxGesture,

        // Local modules
        .project(target: "Presentation", path: "../Presentation"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Core", path: "../Core"),
        .project(target: "Shared", path: "../Shared")
      ],
      settings: .settings(base: [
        "MARKETING_VERSION": "1.3.0",
        "CURRENT_PROJECT_VERSION": "20260113",
        "DEVELOPMENT_TEAM": "YH4A87H8M4",
        "TARGETED_DEVICE_FAMILY": "1",
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
