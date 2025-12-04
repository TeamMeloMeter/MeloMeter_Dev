import ProjectDescription

let project = Project(
  name: "Core",
  targets: [
    .target(
      name: "Core",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.core",
      deploymentTargets: .iOS("16.0"),
      sources: ["../../MeloMeter/Sources/Utils/**"],
      resources: [],
      dependencies: [
          .package(product: "RxSwift"),
          .package(product: "RxCocoa")
      ]
    )
  ]
)
