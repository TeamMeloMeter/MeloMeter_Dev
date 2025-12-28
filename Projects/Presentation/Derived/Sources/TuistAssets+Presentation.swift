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

public enum PresentationAsset: Sendable {
  public static let accentColor = PresentationColors(name: "AccentColor")
  public static let chatBackground = PresentationImages(name: "chatBackground")
  public static let chatCamera = PresentationImages(name: "chatCamera")
  public static let downBtn = PresentationImages(name: "downBtn")
  public static let cancel = PresentationImages(name: "cancel")
  public static let logo = PresentationImages(name: "logo")
  public static let permissionBackG = PresentationImages(name: "permissionBackG")
  public static let progress1 = PresentationImages(name: "progress1")
  public static let progress2 = PresentationImages(name: "progress2")
  public static let progress3 = PresentationImages(name: "progress3")
  public static let progress4 = PresentationImages(name: "progress4")
  public static let addIcon = PresentationImages(name: "addIcon")
  public static let arrowIcon = PresentationImages(name: "arrowIcon")
  public static let backIcon = PresentationImages(name: "backIcon")
  public static let cameraIcon = PresentationImages(name: "cameraIcon")
  public static let couplePlaceIcon = PresentationImages(name: "couplePlaceIcon")
  public static let grabbar = PresentationImages(name: "grabbar")
  public static let completeImage = PresentationImages(name: "completeImage")
  public static let lockImage = PresentationImages(name: "lockImage")
  public static let unlockImage = PresentationImages(name: "unlockImage")
  public static let alarmIcon = PresentationImages(name: "alarmIcon")
  public static let birthDayIcon = PresentationImages(name: "birthDayIcon")
  public static let chatIcon = PresentationImages(name: "chatIcon")
  public static let chatIconSelect = PresentationImages(name: "chatIconSelect")
  public static let mapIcon = PresentationImages(name: "mapIcon")
  public static let mapIconSelect = PresentationImages(name: "mapIconSelect")
  public static let myMarkerDot = PresentationImages(name: "myMarkerDot")
  public static let myMarkerborder = PresentationImages(name: "myMarkerborder")
  public static let myPageIcon = PresentationImages(name: "myPageIcon")
  public static let myPageIconSelect = PresentationImages(name: "myPageIconSelect")
  public static let myPositionIcon = PresentationImages(name: "myPositionIcon")
  public static let otherMarkerDot = PresentationImages(name: "otherMarkerDot")
  public static let otherMarkerborder = PresentationImages(name: "otherMarkerborder")
  public static let messageSearchDown = PresentationImages(name: "message_search_down")
  public static let messageSearchLastDown = PresentationImages(name: "message_search_lastDown")
  public static let messageSearchUp = PresentationImages(name: "message_search_up")
  public static let topImage = PresentationImages(name: "topImage")
  public static let xmark = PresentationImages(name: "xmark")
  public static let noticeIcon = PresentationImages(name: "noticeIcon")
  public static let calIcon = PresentationImages(name: "calIcon")
  public static let defaultProfileImage = PresentationImages(name: "defaultProfileImage")
  public static let heartIcon = PresentationImages(name: "heartIcon")
  public static let hundredQA = PresentationImages(name: "hundredQA")
  public static let infoIcon = PresentationImages(name: "infoIcon")
  public static let newDot = PresentationImages(name: "newDot")
  public static let noticeDotIcon = PresentationImages(name: "noticeDotIcon")
  public static let profileEdit = PresentationImages(name: "profileEdit")
  public static let profileTest = PresentationImages(name: "profileTest")
  public static let qaIcon = PresentationImages(name: "qAIcon")
  public static let topView = PresentationImages(name: "topView")
  public static let pickedMarkerIcon = PresentationImages(name: "pickedMarkerIcon")
  public static let plusIcon = PresentationImages(name: "plusIcon")
  public static let searchIcon = PresentationImages(name: "searchIcon")
  public static let startView = PresentationImages(name: "startView")
  public static let threeDout = PresentationImages(name: "threeDout")
}

// MARK: - Implementation Details

public final class PresentationColors: Sendable {
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

public extension PresentationColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: PresentationColors) {
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
  init(asset: PresentationColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct PresentationImages: Sendable {
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
  init(asset: PresentationImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: PresentationImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: PresentationImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
