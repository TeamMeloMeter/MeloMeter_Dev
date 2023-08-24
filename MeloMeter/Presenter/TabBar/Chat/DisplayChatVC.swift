//
//  BasicExampleViewController.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import Kingfisher
import MapKit
import MessageKit
import UIKit

// MARK: - BasicExampleViewController

final class DisplayChatVC: ChatVC {
    
    private let viewModel: ChatVM
    
    override init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  override func configureMessageCollectionView() {
    super.configureMessageCollectionView()
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }
    
    
  func textCellSizeCalculator(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CellSizeCalculator? {
    nil
  }
}

// MARK: MessagesDisplayDelegate

extension DisplayChatVC: MessagesDisplayDelegate {
  // MARK: - Text Messages

  func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
    isFromCurrentSender(message: message) ? .darkText : .darkText
  }

  func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
    switch detector {
    case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
    default: return MessageLabel.defaultAttributes
    }
  }

  func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
    [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
  }

  // MARK: - All Messages

  func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
      isFromCurrentSender(message: message) ? UIColor.primary1.withAlphaComponent(0.22) : .white
  }
    

  func messageStyle(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
      var corners: UIRectCorner = []

      if isFromCurrentSender(message: message) {
        corners.formUnion(.topLeft)
        corners.formUnion(.bottomLeft)
        if !isPreviousMessageSameSender(at: indexPath) {
          corners.formUnion(.topRight)
        }
        if !isNextMessageSameSender(at: indexPath) {
          corners.formUnion(.bottomRight)
        }
      } else {
        corners.formUnion(.topRight)
        corners.formUnion(.bottomRight)
        if !isPreviousMessageSameSender(at: indexPath) {
          corners.formUnion(.topLeft)
        }
        if !isNextMessageSameSender(at: indexPath) {
          corners.formUnion(.bottomLeft)
        }
      }

      return .custom { view in
        let radius: CGFloat = 16
        let path = UIBezierPath(
          roundedRect: view.bounds,
          byRoundingCorners: corners,
          cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
      }
    }

    func configureAvatarView(
      _ avatarView: AvatarView,
      for message: MessageType,
      at indexPath: IndexPath,
      in _: MessagesCollectionView)
    {
      let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
      avatarView.set(avatar: avatar)
      avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
      avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primary1.cgColor
    }

  // MARK: - Location Messages

  func annotationViewForLocation(message _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MKAnnotationView? {
    let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
    let pinImage = #imageLiteral(resourceName: "myMarkerDot")
    annotationView.image = pinImage
    annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
    return annotationView
  }

  func animationBlockForLocation(
    message _: MessageType,
    at _: IndexPath,
    in _: MessagesCollectionView) -> ((UIImageView) -> Void)?
  {
    { view in
      view.layer.transform = CATransform3DMakeScale(2, 2, 2)
      UIView.animate(
        withDuration: 0.6,
        delay: 0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 0,
        options: [],
        animations: {
          view.layer.transform = CATransform3DIdentity
        },
        completion: nil)
    }
  }

  func snapshotOptionsForLocation(
    message _: MessageType,
    at _: IndexPath,
    in _: MessagesCollectionView)
    -> LocationMessageSnapshotOptions
  {
    LocationMessageSnapshotOptions(
      showsBuildings: true,
      showsPointsOfInterest: true,
      span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
  }

  // MARK: - Audio Messages

  func audioTintColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
    isFromCurrentSender(message: message) ? .white : UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
  }

  func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
    audioController
      .configureAudioCell(
        cell,
        message: message) // this is needed especially when the cell is reconfigure while is playing sound
  }
}

// MARK: MessagesLayoutDelegate

extension DisplayChatVC: MessagesLayoutDelegate {
  func cellTopLabelHeight(for _: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
//    if isTimeLabelVisible(at: indexPath) {
//      return 18
//    }
    return 0
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      let outgoingAvatarOverlap: CGFloat = 17.5
      
    if isFromCurrentSender(message: message) {
      return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
    } else {
      return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
    }
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
  }
 
}
