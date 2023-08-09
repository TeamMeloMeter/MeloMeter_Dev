//
//  ChatViewController.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import InputBarAccessoryView
import MessageKit
import UIKit

// MARK: - ChatViewController

/// A base class for the example controllers
class ChatVC: MessagesViewController, MessagesDataSource {
  // MARK: Internal

  // MARK: - Public properties

  /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
  lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

  lazy var messageList: [MockMessage] = []

  private(set) lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    return control
  }()

  // MARK: - MessagesDataSource

  var currentSender: SenderType {
    SampleData.shared.currentSender
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = "MessageKit"

    configureMessageCollectionView()
    configureMessageInputBar()
    loadFirstMessages()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
      //샘플데이터 출력
//    MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
//      .onNewMessage { [weak self] message in
//        self?.insertMessage(message)
//      }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
      //샘플데이터 멈추기
//    MockSocket.shared.disconnect()
    audioController.stopAnyOngoingPlaying()
  }

  func loadFirstMessages() {
    DispatchQueue.global(qos: .userInitiated).async {
        //처음 몇개를 가져올건지
      let count = UserDefaults.standard.mockMessagesCount()
      SampleData.shared.getMessages(count: count) { messages in
        DispatchQueue.main.async {
          self.messageList = messages
          self.messagesCollectionView.reloadData()
          self.messagesCollectionView.scrollToLastItem(animated: false)
        }
      }
    }
  }

  @objc
  func loadMoreMessages() {
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
      SampleData.shared.getMessages(count: 20) { messages in
        DispatchQueue.main.async {
          self.messageList.insert(contentsOf: messages, at: 0)
          self.messagesCollectionView.reloadDataAndKeepOffset()
          self.refreshControl.endRefreshing()
        }
      }
    }
  }

  func configureMessageCollectionView() {
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messageCellDelegate = self

    scrollsToLastItemOnKeyboardBeginsEditing = true // default false
    maintainPositionOnInputBarHeightChanged = true // default false
    showMessageTimestampOnSwipeLeft = true // default false

    messagesCollectionView.refreshControl = refreshControl
  }

  func configureMessageInputBar() {
    messageInputBar.delegate = self
    messageInputBar.inputTextView.tintColor = .primary1
    messageInputBar.sendButton.setTitleColor(.primary1, for: .normal)
    messageInputBar.sendButton.setTitleColor(
      UIColor.primary1.withAlphaComponent(0.3),
      for: .highlighted)
  }

  // MARK: - Helpers
    //MockMessage 형태로 입력받아 scrollToLastItem(마지막 아이탬에 추가한다)
  func insertMessage(_ message: MockMessage) {
    messageList.append(message)
    // Reload last section to update header/footer labels and insert a new one
    messagesCollectionView.performBatchUpdates({
      messagesCollectionView.insertSections([messageList.count - 1])
      if messageList.count >= 2 {
        messagesCollectionView.reloadSections([messageList.count - 2])
      }
    }, completion: { [weak self] _ in
      if self?.isLastSectionVisible() == true {
        self?.messagesCollectionView.scrollToLastItem(animated: true)
      }
    })
  }

  func isLastSectionVisible() -> Bool {
    guard !messageList.isEmpty else { return false }

    let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

    return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
  }

  func numberOfSections(in _: MessagesCollectionView) -> Int {
    messageList.count
  }

  func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
    messageList[indexPath.section]
  }

  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if indexPath.section % 3 == 0 {
      return NSAttributedString(
        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
        attributes: [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
          NSAttributedString.Key.foregroundColor: UIColor.darkGray,
        ])
    }
    return nil
  }

  func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
    NSAttributedString(
      string: "Read",
      attributes: [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
        NSAttributedString.Key.foregroundColor: UIColor.darkGray,
      ])
  }

  func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
  }

  func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
    let dateString = formatter.string(from: message.sentDate)
    return NSAttributedString(
      string: dateString,
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
  }

  func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
    nil
  }

  // MARK: Private

  // MARK: - Private properties

  private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()
}

// MARK: MessageCellDelegate

extension ChatVC: MessageCellDelegate {
  func didTapAvatar(in _: MessageCollectionViewCell) {
    print("Avatar tapped")
  }

  func didTapMessage(in _: MessageCollectionViewCell) {
    print("Message tapped")
  }

  func didTapImage(in _: MessageCollectionViewCell) {
    print("Image tapped")
  }

  func didTapCellTopLabel(in _: MessageCollectionViewCell) {
    print("Top cell label tapped")
  }

  func didTapCellBottomLabel(in _: MessageCollectionViewCell) {
    print("Bottom cell label tapped")
  }

  func didTapMessageTopLabel(in _: MessageCollectionViewCell) {
    print("Top message label tapped")
  }

  func didTapMessageBottomLabel(in _: MessageCollectionViewCell) {
    print("Bottom label tapped")
  }

  func didTapPlayButton(in cell: AudioMessageCell) {
    guard
      let indexPath = messagesCollectionView.indexPath(for: cell),
      let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
    else {
      print("Failed to identify message when audio cell receive tap gesture")
      return
    }
    guard audioController.state != .stopped else {
      // There is no audio sound playing - prepare to start playing for given audio message
      audioController.playSound(for: message, in: cell)
      return
    }
    if audioController.playingMessage?.messageId == message.messageId {
      // tap occur in the current cell that is playing audio sound
      if audioController.state == .playing {
        audioController.pauseSound(for: message, in: cell)
      } else {
        audioController.resumeSound()
      }
    } else {
      // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
      audioController.stopAnyOngoingPlaying()
      audioController.playSound(for: message, in: cell)
    }
  }

  func didStartAudio(in _: AudioMessageCell) {
    print("Did start playing audio sound")
  }

  func didPauseAudio(in _: AudioMessageCell) {
    print("Did pause audio sound")
  }

  func didStopAudio(in _: AudioMessageCell) {
    print("Did stop audio sound")
  }

  func didTapAccessoryView(in _: MessageCollectionViewCell) {
    print("Accessory view tapped")
  }
}

// MARK: MessageLabelDelegate

extension ChatVC: MessageLabelDelegate {
  func didSelectAddress(_ addressComponents: [String: String]) {
    print("Address Selected: \(addressComponents)")
  }

  func didSelectDate(_ date: Date) {
    print("Date Selected: \(date)")
  }

  func didSelectPhoneNumber(_ phoneNumber: String) {
    print("Phone Number Selected: \(phoneNumber)")
  }

  func didSelectURL(_ url: URL) {
    print("URL Selected: \(url)")
  }

  func didSelectTransitInformation(_ transitInformation: [String: String]) {
    print("TransitInformation Selected: \(transitInformation)")
  }

  func didSelectHashtag(_ hashtag: String) {
    print("Hashtag selected: \(hashtag)")
  }

  func didSelectMention(_ mention: String) {
    print("Mention selected: \(mention)")
  }

  func didSelectCustom(_ pattern: String, match _: String?) {
    print("Custom data detector patter selected: \(pattern)")
  }
}

// MARK: InputBarAccessoryViewDelegate

extension ChatVC: InputBarAccessoryViewDelegate {
  // MARK: Internal

  @objc
  func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
    processInputBar(messageInputBar)
  }

  func processInputBar(_ inputBar: InputBarAccessoryView) {
    // Here we can parse for which substrings were autocompleted
    let attributedText = inputBar.inputTextView.attributedText!
    let range = NSRange(location: 0, length: attributedText.length)
    attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

      let substring = attributedText.attributedSubstring(from: range)
      let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
      print("Autocompleted: `", substring, "` with context: ", context ?? [])
    }

    let components = inputBar.inputTextView.components
    inputBar.inputTextView.text = String()
    inputBar.invalidatePlugins()
    // Send button activity animation
    inputBar.sendButton.startAnimating()
    inputBar.inputTextView.placeholder = "Sending..."
    // Resign first responder for iPad split view
    inputBar.inputTextView.resignFirstResponder()
    DispatchQueue.global(qos: .default).async {
      // fake send request task
      sleep(1)
      DispatchQueue.main.async { [weak self] in
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = "Aa"
        self?.insertMessages(components) // < == 눈에 보이는것만 있음
        // 여기에
        self?.messagesCollectionView.scrollToLastItem(animated: true)
      }
    }
  }

  // MARK: Private
    //샘플 데이터
    
  private func insertMessages(_ data: [Any]) {
    for component in data {
      let user = SampleData.shared.currentSender
      if let str = component as? String {
        let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
        insertMessage(message)
      } else if let img = component as? UIImage {
        let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
        insertMessage(message)
      }
    }
  }
}
