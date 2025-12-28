import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Domain",
  packages: ProjectPackages.all,
  targets: [
    .target(
      name: "Domain",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.teamMeloMeter.domain",
      deploymentTargets: .iOS("16.0"),
      sources: ["Sources/**"],
      resources: [],
      dependencies: [
        // Firebase
        ExternalDependencies.firebaseAnalytics,
        ExternalDependencies.firebaseAuth,

        // Google Ads
        ExternalDependencies.googleMobileAds,

        // Rx
        ExternalDependencies.rxSwift,
        ExternalDependencies.rxRelay
      ],
      settings: .settings(base: [
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
