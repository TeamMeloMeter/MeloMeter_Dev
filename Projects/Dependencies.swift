import ProjectDescription

let dependencies = Dependencies(
  swiftPackageManager: .init(
    [
      .remote(url: "https://github.com/ReactiveX/RxSwift.git", requirement: .upToNextMajor(from: "6.9.1")),
      .remote(url: "https://github.com/MessageKit/MessageKit.git", requirement: .upToNextMajor(from: "4.0.0")),
      .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.10.2")),
      .remote(url: "https://github.com/SnapKit/SnapKit.git", requirement: .upToNextMajor(from: "5.7.1")),
      .remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "8.6.1")),
      .remote(url: "https://github.com/luximetr/AnyFormatKit.git", requirement: .upToNextMajor(from: "2.5.2"))
      // 🔹 Firebase, Kakao 등도 여기에 추가 가능
    ]
  ),
  platforms: [.iOS]
)
