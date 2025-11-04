//
//  Project.swift
//  MeloMeter
//
//  Created by 양승완 on 11/4/25.
//


// Project.swift
import ProjectDescription

let project = Project(
    name: "Melometer", // <- 프로젝트 이름
    organizationName: "com.teamMeloMeter.-",
    packages: [
        // 네가 Pods에서 쓰던 라이브러리들 전부 SPM 버전
        .package(url: "https://github.com/Alamofire/Alamofire.git",
                 .upToNextMajor(from: "5.0.0")),                    // Alamofire:contentReference[oaicite:2]{index=2}
        .package(url: "https://github.com/luximetr/AnyFormatKit.git",
                 .upToNextMajor(from: "2.5.2")),                    // AnyFormatKit:contentReference[oaicite:3]{index=3}
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
                 .upToNextMajor(from: "12.0.0")),                   // GoogleMobileAds:contentReference[oaicite:4]{index=4}
        .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git",
                 .upToNextMajor(from: "3.0.0")),                    // GoogleUserMessagingPlatform (UMP):contentReference[oaicite:5]{index=5}
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git",
                 .upToNextMajor(from: "2.0.0")),                    // Kakao SDK 묶음:contentReference[oaicite:6]{index=6}
        .package(url: "https://github.com/onevcat/Kingfisher.git",
                 .upToNextMajor(from: "8.0.0")),                    // Kingfisher:contentReference[oaicite:7]{index=7}
        .package(url: "https://github.com/navermaps/SPM-NMapsMap.git",
                 .upToNextMajor(from: "3.16.0")),                   // NMapsMap + NMapsGeometry:contentReference[oaicite:8]{index=8}
        .package(url: "https://github.com/ReactiveX/RxSwift.git",
                 .upToNextMajor(from: "6.0.0")),                    // RxSwift / RxCocoa / RxRelay:contentReference[oaicite:9]{index=9}
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git",
                 .upToNextMajor(from: "4.0.0")),                    // RxGesture:contentReference[oaicite:10]{index=10}
        .package(url: "https://github.com/SnapKit/SnapKit.git",
                 .upToNextMajor(from: "5.0.0")),                    // SnapKit:contentReference[oaicite:11]{index=11}
        .package(url: "https://github.com/devxoul/Then.git",
                 .upToNextMajor(from: "3.0.0"))                     // Then:contentReference[oaicite:12]{index=12}
    ],
    targets: [
        .target(
            name: "MeloMeter", // <- 네 앱 타깃 이름
            platform: .iOS,
            product: .app,
            bundleId: "com.teamMeloMeter.-",
            deploymentTarget: .iOS(targetVersion: "15.0", devices: [.iphone]),
            infoPlist: .file(path: "MyApp/Info.plist"),
            sources: ["MyApp/Sources/**"],
            resources: ["MyApp/Resources/**"],
            dependencies: [
                // 여기서 필요한 것만 골라서 쓰면 됨
                .package(product: "Alamofire"),
                .package(product: "AnyFormatKit"),

                .package(product: "GoogleMobileAds"),
                .package(product: "GoogleUserMessagingPlatform"),

                .package(product: "KakaoSDK"),
                .package(product: "KakaoSDKAuth"),
                .package(product: "KakaoSDKCommon"),
                .package(product: "KakaoSDKUser"),
                .package(product: "KakaoSDKTalk"),
                .package(product: "KakaoSDKFriend"),
                .package(product: "KakaoSDKTemplate"),
                .package(product: "KakaoSDKShare"),
                .package(product: "KakaoSDKCert"),
                .package(product: "KakaoSDKCertCore"),
                .package(product: "KakaoSDKFriendCore"),

                .package(product: "Kingfisher"),

                .package(product: "NMapsMap"),
                .package(product: "NMapsGeometry"),

                .package(product: "RxSwift"),
                .package(product: "RxCocoa"),
                .package(product: "RxRelay"),
                .package(product: "RxGesture"),

                .package(product: "SnapKit"),
                .package(product: "Then")
            ]
        )
    ]
)
