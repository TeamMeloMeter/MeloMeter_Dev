import ProjectDescription

let project = Project(
  name: "Domain",
  targets: [
    .target(
      name: "Domain",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.domain",
      deploymentTargets: .iOS("16.0"),
      sources: ["../../MeloMeter/Sources/Domain/**"],
      resources: [],
      dependencies: []
    )
  ]
)
