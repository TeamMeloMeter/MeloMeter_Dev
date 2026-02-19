// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TuistDependencies",
    dependencies: [
        // Kakao iOS SDK (SPM)
        .package(
            url: "https://github.com/kakao/kakao-ios-sdk",
            .upToNextMajor(from: "2.22.0")
        )
        // 필요하면 여기 뒤에 다른 SPM 패키지들 계속 추가하면 됨
        // 예: Firebase, GoogleMobileAds 등
        // .package(url: "...", .upToNextMajor(from: "x.y.z")),
    ]
)
