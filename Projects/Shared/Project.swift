import ProjectDescription

let project = Project(
  name: "Shared",
  targets: [
    .target(
      name: "Shared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.shared",
      deploymentTargets: .iOS("16.0"),
      sources: [],
      resources: ["../../MeloMeter/Resources/**"],
      dependencies: []
    )
  ]
)
