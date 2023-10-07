//
//  ChatViewController.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import InputBarAccessoryView
import MessageKit
import UIKit
import RxCocoa
import RxSwift
import RxGesture
// MARK: - ChatViewController

/// A base class for the example controllers
class ChatVC: MessagesViewController, MessagesDataSource {
    
    private let viewModel: ChatVM?
    let disposeBag = DisposeBag()
    let tapGesture = UITapGestureRecognizer()
    let viewDidLoadEvent = PublishSubject<Void>()
    let reloadEvent = PublishSubject<Int>()
    var sendTextMessage = PublishRelay<MockMessage>()
    var sendImageMessage = PublishRelay<MockMessage>()
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    lazy var messageList: [MockMessage] = []

    // 백그라운드 이미지
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chatBackground")
        return imageView
    }()
    
    //자기 자신이 될 MockUser셋팅
    let mockUser = MockUser(senderId: UserDefaults.standard.string(forKey: "uid") ?? "", displayName: UserDefaults.standard.string(forKey: "userName") ?? "")
    var currentSender: SenderType {
        self.mockUser
    }
    
    let mockUser2 = MockUser(senderId: "test1", displayName: "test2")
    
    
    
    init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(reloadMessageEvent), for: .valueChanged)
        return control
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
        self.viewDidLoadEvent.onNext(())
        setNavigationBar()
        configureMessageCollectionView()
        configureMessageInputBar()
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        setBgAutoLayout()
    }
    
    // MARK: 오토레이아웃
    func setBgAutoLayout() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureMessageInputBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if !self.messageList.isEmpty {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: self.messageList.count-1), at: .centeredVertically, animated: false)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stopAnyOngoingPlaying()
    }
    
    // MARK: - 처음 로딩시 채팅 리스트 가져오는곳
    func loadFirstMessages(_ chatMassageList: [MockMessage]) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.messageList = chatMassageList // DB에서 받아온 메세지 배열 삽입
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: false)
            }
        }
    }
    // 새로고침 이벤트
    @objc func reloadMessageEvent() {
        self.reloadEvent.onNext(self.messageList.count)
    }

    func loadMoreMessages(_ chatMassageList: [MockMessage]) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            //받아온 매시지 리스트를 하나씩 삽입한다,
            DispatchQueue.main.async {
                self.messageList.insert(contentsOf: chatMassageList, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "채팅"
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    private lazy var backBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "backIcon"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()
    
    // MARK: Configure
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundView = backgroundImageView
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        messagesCollectionView.refreshControl = refreshControl
        self.messageInputBar.inputTextView.placeholder = " 메세지를 입력해주세요."
        
    }
    
    func configureMessageInputBar() {
        
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.backgroundColor = .white
        messageInputBar.inputTextView.tintColor = .gray2
        messageInputBar.sendButton.setTitleColor(.gray2, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.gray2.withAlphaComponent(0.3),
            for: .highlighted)
        messageInputBar.sendButton.titleLabel?.font = FontManager.shared.regular(ofSize: 14)
        messageInputBar.isTranslucent = false
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .gray2
        messageInputBar.inputTextView.backgroundColor = .gray5
        messageInputBar.inputTextView.placeholderTextColor = .gray2
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 11.5, left: 14, bottom: 11.5, right: 60)
        messageInputBar.inputTextView.layer.cornerRadius = 8
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.inputTextView.placeholder = " 메세지를 입력해주세요."
        configureInputBarItems()
        inputBarType = .custom(messageInputBar)
    }
    
    // MARK: - EVENT
    func messageSendfaileAlert(){
        AlertManager(viewController: self)
            .setTitle("전송실패")
            .setMessage("서버와 연결에 실패했습니다.\n잠시후에 다시 시도해주세요. ")
            .addActionConfirm("확인")
            .showCustomAlert()
    }
    
    //인풋바 아이탬 설정
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.backgroundColor = .gray5
        messageInputBar.sendButton.setSize(CGSize(width: 44, height: 44), animated: false)
        messageInputBar.sendButton.title = "전송"
        messageInputBar.sendButton.layer.cornerRadius = 8
        messageInputBar.sendButton.layer.masksToBounds = true
        configureInputBarPadding()
        
    }
    
    private func configureInputBarPadding() {
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.right = -52
        messageInputBar.inputTextView.textContainerInset.bottom = 8
    }
  
    @objc func viewDidLoadEventMethod(){}
    
    
    // MARK: - Helpers
    
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func isNextMessageSameDate(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return areSameDates(date1: messageList[indexPath.section].sentDate, date2: messageList[indexPath.section + 1].sentDate)
    }
    
    func areSameDates(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day && components1.minute == components2.minute
    }
    
    
    // MARK: - Binding
    func setBindings() {        
        let input = ChatVM.Input(
            viewDidLoadEvent: self.viewDidLoadEvent
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            mySendTextMessage: self.sendTextMessage
                .asObservable(),
            mySendImageMessage: self.sendImageMessage
                .asObservable(),
            reloadMessage: self.reloadEvent
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
          
        output.senddSuccess
            .bind(onNext: {result in
                if result {
                    //성공
                }
                else {
                    self.messageSendfaileAlert()
                }
            })
            .disposed(by: disposeBag)
        
        output.getMessage
            .bind(onNext: {chatMessageList in
                self.loadFirstMessages(chatMessageList)
            })
            .disposed(by: disposeBag)
        
        output.getMoreMessage
            .bind(onNext: {chatMessageList in
                // 여기에 메세지를 추가로 늘려주는 함수가 필요하다.
                self.loadMoreMessages(chatMessageList)
            })
            .disposed(by: disposeBag)
        
        output.getRealTimeMessage
            .bind(onNext: {chatMessageList in
                chatMessageList.forEach{ chatMessage in
                    self.insertMessage(chatMessage)
                }
            })
            .disposed(by: disposeBag)
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
                self?.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: true)
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
    
    //여기에서 일이 넘어갈때만 출력하도록 ( 00,00,00 시에 가장 가까운 매세지에 한번 출력 )
    // 인덱스패스를 통해 바로 이전 메세지에서 데이트 차이가 -가 되는 경우에만 출력
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard self.messageList.last != nil else{ return nil }
        
        if indexPath.section - 1 > 0{
            if !datesCompare(date1: messageList[indexPath.section - 1].sentDate, date2: message.sentDate){
                return NSAttributedString(
                    string: message.sentDate.toString(type: .yearAndMonthAndDate),
                    attributes: [
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                        NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                    ])
            }
        }
        return nil
    }
    
    func datesCompare(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.toString(type: .chatDate)
        if !isNextMessageSameSender(at: indexPath) {
            return NSAttributedString(
                string: dateString,
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.gray2
                ])
        }else if isNextMessageSameSender(at: indexPath) {
            if !isNextMessageSameDate(at: indexPath) {
                return NSAttributedString(
                    string: dateString,
                    attributes: [
                        NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 10),
                        NSAttributedString.Key.foregroundColor: UIColor.gray2
                    ])
                
            }else {
                return nil
            }
        }else {
            return nil
        }
        
    }

    // MARK: TextCustomCell
    func textCell(for message: MessageType, at indexPath: IndexPath, in messageView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomMessageCell", for: indexPath) as! CustomMessageCell
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)

        return cell
    }
    // MARK: PhotoCustomCell
    func photoCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoCell", for: indexPath) as! CustomPhotoCell
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)

        return cell
    }

    // MARK: - Private properties
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
}

// MARK: MessageCellDelegate

extension ChatVC: MessageCellDelegate {
    func didTapAvatar(in _: MessageCollectionViewCell) {
        
        print("Avatar tapped", messageList.count)
        
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
    
    func didTapMessageBottomLabel(in a: MessageCollectionViewCell) {
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
    
    //보내기 버튼 클릭 이벤트
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
        }
        
        let components = inputBar.inputTextView.components //String
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "이것좀 없애자"
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = " 메세지를 입력해주세요."
                //챗팅창에 보이게 하는 메서드
                self?.insertMessages(components)
                //컬렉션 뷰 마지막으로 스크롤 이동
                self?.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: true)
            }
        }
    }
    
    // MARK: Private
    private func insertMessages(_ data: [Any]) {
        for component in data {
            //텍스트 타입
            if let str = component as? String {
                
                let message = MockMessage(text: str, user: self.mockUser, messageId: UUID().uuidString, date: Date.fromStringOrNow(Date().toString(type: .timeStamp), .timeStamp))
                sendTextMessage.accept(message)
            }
        }
    }
}

// MARK: CameraInputBarAccessoryViewDelegate

extension ChatVC: CameraInputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        for item in attachments {
            if case .image(let image) = item {
                self.sendImageMessageEvent(photo: image)
            }
        }
        inputBar.invalidatePlugins()
    }
    
    //이미지타입 전송
    func sendImageMessageEvent(photo: UIImage) {
        
        let photoMessage = MockMessage(image: photo, user: currentSender as! MockUser, messageId: UUID().uuidString, date: Date())
        sendImageMessage.accept(photoMessage)
    }
}

