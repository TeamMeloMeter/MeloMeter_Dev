// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum SharedAsset: Sendable {
  public static let accentColor = SharedColors(name: "AccentColor")
  public static let chatBackground = SharedImages(name: "chatBackground")
  public static let chatCamera = SharedImages(name: "chatCamera")
  public static let downBtn = SharedImages(name: "downBtn")
  public static let cancel = SharedImages(name: "cancel")
  public static let logo = SharedImages(name: "logo")
  public static let permissionBackG = SharedImages(name: "permissionBackG")
  public static let progress1 = SharedImages(name: "progress1")
  public static let progress2 = SharedImages(name: "progress2")
  public static let progress3 = SharedImages(name: "progress3")
  public static let progress4 = SharedImages(name: "progress4")
  public static let addIcon = SharedImages(name: "addIcon")
  public static let arrowIcon = SharedImages(name: "arrowIcon")
  public static let backIcon = SharedImages(name: "backIcon")
  public static let cameraIcon = SharedImages(name: "cameraIcon")
  public static let couplePlaceIcon = SharedImages(name: "couplePlaceIcon")
  public static let grabbar = SharedImages(name: "grabbar")
  public static let completeImage = SharedImages(name: "completeImage")
  public static let lockImage = SharedImages(name: "lockImage")
  public static let unlockImage = SharedImages(name: "unlockImage")
  public static let alarmIcon = SharedImages(name: "alarmIcon")
  public static let birthDayIcon = SharedImages(name: "birthDayIcon")
  public static let chatIcon = SharedImages(name: "chatIcon")
  public static let chatIconSelect = SharedImages(name: "chatIconSelect")
  public static let mapIcon = SharedImages(name: "mapIcon")
  public static let mapIconSelect = SharedImages(name: "mapIconSelect")
  public static let myMarkerDot = SharedImages(name: "myMarkerDot")
  public static let myMarkerborder = SharedImages(name: "myMarkerborder")
  public static let myPageIcon = SharedImages(name: "myPageIcon")
  public static let myPageIconSelect = SharedImages(name: "myPageIconSelect")
  public static let myPositionIcon = SharedImages(name: "myPositionIcon")
  public static let otherMarkerDot = SharedImages(name: "otherMarkerDot")
  public static let otherMarkerborder = SharedImages(name: "otherMarkerborder")
  public static let messageSearchDown = SharedImages(name: "message_search_down")
  public static let messageSearchLastDown = SharedImages(name: "message_search_lastDown")
  public static let messageSearchUp = SharedImages(name: "message_search_up")
  public static let topImage = SharedImages(name: "topImage")
  public static let xmark = SharedImages(name: "xmark")
  public static let noticeIcon = SharedImages(name: "noticeIcon")
  public static let calIcon = SharedImages(name: "calIcon")
  public static let defaultProfileImage = SharedImages(name: "defaultProfileImage")
  public static let heartIcon = SharedImages(name: "heartIcon")
  public static let hundredQA = SharedImages(name: "hundredQA")
  public static let infoIcon = SharedImages(name: "infoIcon")
  public static let newDot = SharedImages(name: "newDot")
  public static let noticeDotIcon = SharedImages(name: "noticeDotIcon")
  public static let profileEdit = SharedImages(name: "profileEdit")
  public static let profileTest = SharedImages(name: "profileTest")
  public static let qaIcon = SharedImages(name: "qAIcon")
  public static let topView = SharedImages(name: "topView")
  public static let pickedMarkerIcon = SharedImages(name: "pickedMarkerIcon")
  public static let plusIcon = SharedImages(name: "plusIcon")
  public static let searchIcon = SharedImages(name: "searchIcon")
  public static let startView = SharedImages(name: "startView")
  public static let threeDout = SharedImages(name: "threeDout")
}

// MARK: - Implementation Details

public final class SharedColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension SharedColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: SharedColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: SharedColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct SharedImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: SharedImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: SharedImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: SharedImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
