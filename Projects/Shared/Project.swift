import ProjectDescription

let project = Project(
  name: "Shared",
  targets: [
    .target(
      name: "Shared",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.teamMeloMeter.shared",
      deploymentTargets: .iOS("16.0"),
      sources: ["Sources/**"],
      resources: ["../MeloMeter/Resources/**"],
      dependencies: [],
      settings: .settings(base: [
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
