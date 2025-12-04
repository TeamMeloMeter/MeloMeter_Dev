import ProjectDescription

let project = Project(
  name: "Presentation",
  targets: [
    .target(
      name: "Presentation",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.presentation",
      deploymentTargets: .iOS("16.0"),
      sources: [
        "../../MeloMeter/Sources/Presenter/**",
        "../../MeloMeter/ProfileInput/Views/**",
        "../../MeloMeter/Views/**"
      ],
      resources: ["../../MeloMeter/Resources/**"],
      dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Core", path: "../Core"),
        .project(target: "Shared", path: "../Shared")
      ]
    )
  ]
)
