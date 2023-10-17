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
    let viewDidLoadEvent = PublishSubject<Void>()
    let reloadEvent = PublishSubject<Int>()
    var sendTextMessage = PublishRelay<ChatModel>()
    var sendImageMessage = PublishRelay<ChatModel>()
    lazy var messageList: [ChatModel] = []

    // 백그라운드 이미지
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chatBackground")
        return imageView
    }()
    
    //자기 자신이 될 ChatUser셋팅
    let chatUser = ChatUserModel(senderId: UserDefaults.standard.string(forKey: "uid") ?? "", displayName: UserDefaults.standard.string(forKey: "userName") ?? "")
    var currentSender: SenderType {
        self.chatUser
    }
    
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
                self.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: self.messageList.count-1), at: .centeredVertically, animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - 처음 로딩시 채팅 리스트 가져오는곳
    func loadFirstMessages(_ chatMassageList: [ChatModel]) {
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

    func loadMoreMessages(_ chatMassageList: [ChatModel]) {
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
        self.view.rx.tapGesture().when(.ended)
            .subscribe(onNext: { _ in
                self.inputContainerView.endEditing(true)
            })
            .disposed(by: disposeBag)
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
                }
                else {
                    self.messageSendfaileAlert()
                }
            })
            .disposed(by: disposeBag)
        
        output.getMessage
            .bind(onNext: {chatMessageList in
                self.messageList = chatMessageList
                self.loadFirstMessages(chatMessageList)
            })
            .disposed(by: disposeBag)
        
        output.getMoreMessage
            .bind(onNext: {chatMessageList in
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
    func insertMessage(_ message: ChatModel) {
        messageList.append(message)
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

// MARK: InputBarAccessoryViewDelegate

extension ChatVC: InputBarAccessoryViewDelegate {
    // MARK: Internal
    
    //보내기 버튼 클릭 이벤트
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        let components = inputBar.inputTextView.components //String
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                inputBar.inputTextView.placeholder = " 메세지를 입력해주세요."
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: true)
                
            }
        }
    }
    
    // MARK: Private
    private func insertMessages(_ data: [Any]) {
        for component in data {
            //텍스트 타입
            if let str = component as? String {
                let message = ChatModel(text: str, user: self.chatUser, messageId: UUID().uuidString, date: Date.fromStringOrNow(Date().toString(type: .timeStamp), .timeStamp))
                sendTextMessage.accept(message)
            }
        }
    }
}

// MARK: CameraInputBarAccessoryViewDelegate

extension ChatVC: CameraInputBarAccessoryViewDelegate {
    func sendCameraImage(_ image: UIImage) {
        self.sendImageMessageEvent(photo: image)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        
        //텍스트도 함께 입력된 경우
        if inputBar.inputTextView.text != "" {
            self.insertMessages([inputBar.inputTextView.text ?? ""])
        }
        
        for item in attachments {
            if case .image(let image) = item {
                self.sendImageMessageEvent(photo: image)
            }
        }
    }
    
    func downKeyboard() {
        self.inputContainerView.endEditing(true)
    }
    
    //이미지타입 전송
    func sendImageMessageEvent(photo: UIImage) {
        let photoMessage = ChatModel(image: photo, user: currentSender as! ChatUserModel, messageId: UUID().uuidString, date: Date())
        sendImageMessage.accept(photoMessage)
    }
    
}
