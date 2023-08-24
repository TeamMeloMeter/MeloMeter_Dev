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

// MARK: - ChatViewController

/// A base class for the example controllers
class ChatVC: MessagesViewController, MessagesDataSource {
    
    private let viewModel: ChatVM?
    let disposeBag = DisposeBag()
    let tapGesture = UITapGestureRecognizer()
    let viewDidLoadEvent = PublishSubject<Void>()
    var sendMessage = PublishRelay<MockMessage>()
    
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    lazy var messageList: [MockMessage] = []
    
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
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "MessageKit"
        
        //바인딩 추가
        setBindings()
        self.viewDidLoadEvent.onNext(())
        
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    // MARK: - 처음 로딩시 채팅 리스트 가져오는곳
    func loadFirstMessages(_ chatMassageList: [MockMessage]) {
//        //디스패치 큐로 로컬에서 가져옴
//        DispatchQueue.global(qos: .userInitiated).async {
//            //처음 몇개를 가져올건지
//            let count = UserDefaults.standard.mockMessagesCount()
//            SampleData.shared.getMessages(count: count) { messages in
//                DispatchQueue.main.async {
//                    self.messageList = messages
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToLastItem(animated: false)
//                }
//            }
//        }
        
        //====================
//         message의 기본타입
//         init(text: String, user: MockUser, messageId: String, date: Date) {
//           self.init(kind: .text(text), user: user, messageId: messageId, date: date)
//         }
        
//          MockUser의 기본타입
//        struct MockUser: SenderType, Equatable {
//          var senderId: String
//          var displayName: String
//        }
                
        //화면에 뿌리는 코드
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.messageList = chatMassageList // DB에서 받아온 메세지 배열 삽입
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: false)
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
    
    // MARK: - EVENT
    func messageSendfaileAlert(){
        AlertManager(viewController: self)
            .setTitle("전송실패")
            .setMessage("서버와 연결에 실패했습니다.\n잠시후에 다시 시도해주세요. ")
            .addActionConfirm("확인")
            .showCustomAlert()
    }
    
    
    @objc func viewDidLoadEventMethod(){
        
    }
    
    // MARK: - Binding
    func setBindings() {
        view.addGestureRecognizer(tapGesture)
        
        //바인딩
        let input = ChatVM.Input(
            viewDidLoadEvent: self.viewDidLoadEvent
                .map({ _ in })
                .asObservable(),
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            mySendMessage: self.sendMessage
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
        
        output.getRealTimeMessage
            .bind(onNext: {chatMessageList in
                chatMessageList.map{ chatMessage in
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
    
    //여기에서 일이 넘어갈때만 출력하도록 ( 00,00,00 시에 가장 가까운 매세지에 한번 출력 )
    // 인덱스패스를 통해 바로 이전 메세지에서 데이트 차이가 -가 되는 경우에만 출력
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard let lastMessage = self.messageList.last else{ return nil }
        
        if indexPath.section - 1 > 0{
            if Calendar.current.dateComponents([.day], from: messageList[indexPath.section - 1].sentDate, to: message.sentDate).day ?? 0 < 0 {
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
    
    func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
        NSAttributedString(
            string: "Read",
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.regular(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.gray2,
            ])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
//       let tf = message.sender.senderId
//       if tf{}
        let true_name = "[내이름, 상대방이름]"
        return NSAttributedString(
            string: name,
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.gray2
                        ])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [
                NSAttributedString.Key.font: FontManager.shared.regular(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.gray2,
            ])
    }
    
    func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
        nil //텍스트 셀 피그마에 맞추기
    }
    
    // MARK: - Private properties
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
        //우리가 원하는 형태로 바꿔서
        formatter.dateStyle = .long
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
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                //챗팅창에 보이게 하는 메서드
                self?.insertMessages(components)
                //컬렉션 뷰 마지막으로 스크롤 이동
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    // MARK: Private
    private func insertMessages(_ data: [Any]) {
        for component in data {
            //텍스트 타입
            if let str = component as? String {
                
                let message = MockMessage(text: str, user: self.mockUser, messageId: UUID().uuidString, date: Date.fromStringOrNow(Date().toString(type: .timeStamp), .timeStamp))
                sendMessage.accept(message)
            
            //이미지 타입
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: self.mockUser, messageId: UUID().uuidString, date: Date.fromStringOrNow(Date().toString(type: .timeStamp), .timeStamp))
//                insertMessage(message)
            }
        }
    }
}
