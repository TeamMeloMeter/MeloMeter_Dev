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
    isFromCurrentSender(message: message) ? .white : .darkText
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
    isFromCurrentSender(message: message) ? .primary1 : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
  }

  func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
    let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(tail, .curved)
  }

//  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
//    let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
//    avatarView.set(avatar: avatar)
//  }

  func configureMediaMessageImageView(
    _ imageView: UIImageView,
    for message: MessageType,
    at _: IndexPath,
    in _: MessagesCollectionView)
  {
    if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
      imageView.kf.setImage(with: imageURL)
    } else {
      imageView.kf.cancelDownloadTask()
    }
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
  func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    18
  }

  func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    17
  }

  func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    20
  }

  func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    16
  }
}
