import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Data",
  packages: ProjectPackages.all,
  targets: [
    .target(
      name: "Data",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.teamMeloMeter.data",
      deploymentTargets: .iOS("16.0"),
      sources: [
        "Sources/**"
      ],
      resources: [],
      dependencies: [
        // Firebase
        ExternalDependencies.firebaseAnalytics,
        ExternalDependencies.firebaseAuth,
        ExternalDependencies.firebaseFirestore,
        ExternalDependencies.firebaseFirestoreSwift,
        ExternalDependencies.firebaseStorage,

        // Google Ads
        ExternalDependencies.googleMobileAds,

        // Kakao SDK
        ExternalDependencies.kakaoSDKCommon,
        ExternalDependencies.kakaoSDKAuth,
        ExternalDependencies.kakaoSDKShare,
        ExternalDependencies.kakaoSDKTemplate,
        ExternalDependencies.kakaoSDKTalk,

        // Utility & UI
        ExternalDependencies.alamofire,
        ExternalDependencies.messageKit,

        // Rx
        ExternalDependencies.rxSwift,
        ExternalDependencies.rxCocoa,
        ExternalDependencies.rxRelay,

        .project(target: "Domain", path: "../Domain")
      ],
      settings: .settings(base: [
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
