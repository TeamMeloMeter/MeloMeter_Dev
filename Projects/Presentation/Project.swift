import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Presentation",
  packages: ProjectPackages.all,
  targets: [
    .target(
      name: "Presentation",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.teamMeloMeter.presentation",
      deploymentTargets: .iOS("16.0"),
      sources: [
        "Sources/**"
      ],
      resources: ["../MeloMeter/Resources/**"],
      dependencies: [
        // Google Ads
        ExternalDependencies.googleMobileAds,

        // Utility & UI
        ExternalDependencies.anyFormatKit,
        ExternalDependencies.kingfisher,
        ExternalDependencies.messageKit,
        ExternalDependencies.nMapsMap,
        ExternalDependencies.snapKit,
        ExternalDependencies.then,

        // Rx
        ExternalDependencies.rxSwift,
        ExternalDependencies.rxCocoa,
        ExternalDependencies.rxRelay,
        ExternalDependencies.rxGesture,

        .project(target: "Domain", path: "../Domain"),
        .project(target: "Core", path: "../Core"),
        .project(target: "Shared", path: "../Shared")
      ],
      settings: .settings(base: [
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
