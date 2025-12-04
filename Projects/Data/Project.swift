import ProjectDescription

let project = Project(
  name: "Data",
  targets: [
    .target(
      name: "Data",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.data",
      deploymentTargets: .iOS("16.0"),
      sources: [
        "../../MeloMeter/Sources/Data/**",
        "../../MeloMeter/FirebaseService/**",
        "../../KakaoService/**",
        "../../LocationService/**"
      ],
      resources: [],
      dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Core", path: "../Core")
      ]
    )
  ]
)
