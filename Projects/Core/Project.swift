import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Core",
  packages: ProjectPackages.all,
  targets: [
    .target(
      name: "Core",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.teamMeloMeter.core",
      deploymentTargets: .iOS("16.0"),
      sources: ["Sources/**"],
      resources: [],
      dependencies: [],
      settings: .settings(base: [
        "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
      ])
    )
  ]
)
