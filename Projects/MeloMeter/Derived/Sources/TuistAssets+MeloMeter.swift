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

public enum MeloMeterAsset: Sendable {
  public static let accentColor = MeloMeterColors(name: "AccentColor")
  public static let chatBackground = MeloMeterImages(name: "chatBackground")
  public static let chatCamera = MeloMeterImages(name: "chatCamera")
  public static let downBtn = MeloMeterImages(name: "downBtn")
  public static let cancel = MeloMeterImages(name: "cancel")
  public static let logo = MeloMeterImages(name: "logo")
  public static let permissionBackG = MeloMeterImages(name: "permissionBackG")
  public static let progress1 = MeloMeterImages(name: "progress1")
  public static let progress2 = MeloMeterImages(name: "progress2")
  public static let progress3 = MeloMeterImages(name: "progress3")
  public static let progress4 = MeloMeterImages(name: "progress4")
  public static let addIcon = MeloMeterImages(name: "addIcon")
  public static let arrowIcon = MeloMeterImages(name: "arrowIcon")
  public static let backIcon = MeloMeterImages(name: "backIcon")
  public static let cameraIcon = MeloMeterImages(name: "cameraIcon")
  public static let couplePlaceIcon = MeloMeterImages(name: "couplePlaceIcon")
  public static let grabbar = MeloMeterImages(name: "grabbar")
  public static let completeImage = MeloMeterImages(name: "completeImage")
  public static let lockImage = MeloMeterImages(name: "lockImage")
  public static let unlockImage = MeloMeterImages(name: "unlockImage")
  public static let alarmIcon = MeloMeterImages(name: "alarmIcon")
  public static let birthDayIcon = MeloMeterImages(name: "birthDayIcon")
  public static let chatIcon = MeloMeterImages(name: "chatIcon")
  public static let chatIconSelect = MeloMeterImages(name: "chatIconSelect")
  public static let mapIcon = MeloMeterImages(name: "mapIcon")
  public static let mapIconSelect = MeloMeterImages(name: "mapIconSelect")
  public static let myMarkerDot = MeloMeterImages(name: "myMarkerDot")
  public static let myMarkerborder = MeloMeterImages(name: "myMarkerborder")
  public static let myPageIcon = MeloMeterImages(name: "myPageIcon")
  public static let myPageIconSelect = MeloMeterImages(name: "myPageIconSelect")
  public static let myPositionIcon = MeloMeterImages(name: "myPositionIcon")
  public static let otherMarkerDot = MeloMeterImages(name: "otherMarkerDot")
  public static let otherMarkerborder = MeloMeterImages(name: "otherMarkerborder")
  public static let messageSearchDown = MeloMeterImages(name: "message_search_down")
  public static let messageSearchLastDown = MeloMeterImages(name: "message_search_lastDown")
  public static let messageSearchUp = MeloMeterImages(name: "message_search_up")
  public static let topImage = MeloMeterImages(name: "topImage")
  public static let xmark = MeloMeterImages(name: "xmark")
  public static let noticeIcon = MeloMeterImages(name: "noticeIcon")
  public static let calIcon = MeloMeterImages(name: "calIcon")
  public static let defaultProfileImage = MeloMeterImages(name: "defaultProfileImage")
  public static let heartIcon = MeloMeterImages(name: "heartIcon")
  public static let hundredQA = MeloMeterImages(name: "hundredQA")
  public static let infoIcon = MeloMeterImages(name: "infoIcon")
  public static let newDot = MeloMeterImages(name: "newDot")
  public static let noticeDotIcon = MeloMeterImages(name: "noticeDotIcon")
  public static let profileEdit = MeloMeterImages(name: "profileEdit")
  public static let profileTest = MeloMeterImages(name: "profileTest")
  public static let qaIcon = MeloMeterImages(name: "qAIcon")
  public static let topView = MeloMeterImages(name: "topView")
  public static let pickedMarkerIcon = MeloMeterImages(name: "pickedMarkerIcon")
  public static let plusIcon = MeloMeterImages(name: "plusIcon")
  public static let searchIcon = MeloMeterImages(name: "searchIcon")
  public static let startView = MeloMeterImages(name: "startView")
  public static let threeDout = MeloMeterImages(name: "threeDout")
}

// MARK: - Implementation Details

public final class MeloMeterColors: Sendable {
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

public extension MeloMeterColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: MeloMeterColors) {
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
  init(asset: MeloMeterColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct MeloMeterImages: Sendable {
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
  init(asset: MeloMeterImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: MeloMeterImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: MeloMeterImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
