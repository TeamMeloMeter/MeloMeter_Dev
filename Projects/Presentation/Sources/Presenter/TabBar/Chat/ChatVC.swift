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
import SnapKit
import Then
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif
// MARK: - ChatViewController

/// A base class for the example controllers
public class ChatVC: MessagesViewController, MessagesDataSource {
    // MARK: by seungwan
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 불투명하게 설정
        appearance.backgroundColor = .white        // 원하는 배경색 지정
        appearance.shadowColor = .clear
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance
        }

        // 타이틀 텍스트 색상 (선택 사항)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]

        // 네비게이션 바에 적용
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        if #available(iOS 16.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.isTranslucent = false
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            navigationController?.navigationBar.backIndicatorImage = backImage
            navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        }
        navigationController?.navigationBar.tintColor = .gray1
    }
    
    private let viewModel: ChatVM?
    public let disposeBag = DisposeBag()
    public let viewDidLoadEvent = PublishSubject<Void>()
    public let reloadEvent = PublishSubject<Int>()
    public var sendTextMessage = PublishRelay<ChatModel>()
    public var sendImageMessage = PublishRelay<ChatModel>()
    public var searchBtnTappedEvent = PublishSubject<Void>()
    lazy var messageList: [ChatModel] = []
    private var firstLoaded = false

    // 백그라운드 이미지
    public let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chatBackground")
        return imageView
    }()
    
    // 자기 자신이 될 ChatUser셋팅
    public let chatUser = ChatUserModel(senderId: UserDefaults.standard.string(forKey: "uid") ?? "", displayName: UserDefaults.standard.string(forKey: "name") ?? "")
    public var currentSender: SenderType {
        self.chatUser
    }
    
    public init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(reloadMessageEvent), for: .valueChanged)
        return control
    }()
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarAppearance()
        setBindings()
        self.viewDidLoadEvent.onNext(())
        setNavigationBar()
        configureMessageCollectionView()
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        setBgAutoLayout()
    }
    
    // MARK: 오토레이아웃
    public func setBgAutoLayout() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        self.navigationController?.view.backgroundColor = .white
        
        configureMessageInputBar()
        
     
  
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.async {
//            if !self.messageList.isEmpty {
//                self.messagesCollectionView.reloadDataAndKeepOffset()
//                self.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: false)
//            }
//        }
        
        
        self.view.addSubview(moveLastBtn)

        moveLastBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(0)
            $0.bottom.equalTo(inputContainerView.snp.top)
            $0.width.height.equalTo(50)

        }
   
   
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - 처음 로딩시 채팅 리스트 가져오는곳 -> 필요 없을 듯 (seungwan)
    public func loadFirstMessages(_ chatMassageList: [ChatModel]) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                
                self.messageList = chatMassageList // DB에서 받아온 메세지 배열 삽입
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: false)
                self.firstLoaded = true
            }
        }
    }
    // 새로고침 이벤트
    @objc func reloadMessageEvent() {
        self.reloadEvent.onNext(self.messageList.count)
    }

    public func loadMoreMessages(_ chatMassageList: [ChatModel]) {

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2) {
            // 받아온 매시지 리스트를 하나씩 삽입한다,
            DispatchQueue.main.async {

                self.messageList.insert(contentsOf: chatMassageList, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
                
                
//                self.messagesCollectionView.visibleCells.forEach { cell in
//                    if let pickedCell = cell as? TextMessageCell, let fieldText = self.testTextField.text, let cellText = pickedCell.messageLabel.text, cellText.contains(fieldText) {
//                        pickedCell.messageLabel.highlightText(fieldText)
//                        print(pickedCell.messageLabel.text)
//                    }
//                }
            }

       
            
            
        }
    }
    
    // MARK: by seungwan
    public let messageSearchTextField = UITextField().then {
        $0.placeholder = "메세지 검색"
        $0.font = FontManager.shared.regular(ofSize: 16)
        $0.returnKeyType = .search
        $0.isHidden = true
    }
    public let chatLabel = UILabel().then {
        $0.text = "채팅"
        $0.font = FontManager.shared.semiBold(ofSize: 16)
        $0.textAlignment = .center
    }
    
    // TODO: - 맨 밑으로 내려오는 이미지 custom
    public let moveLastBtn = UIImageView().then {
        $0.image = UIImage(named: "message_search_lastDown")
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        let searchTextBar = UIView().then {
            $0.addSubview(messageSearchTextField)
            $0.addSubview(chatLabel)

            chatLabel.snp.makeConstraints {
                $0.top.bottom.trailing.leading.equalToSuperview()
            }
            messageSearchTextField.snp.makeConstraints {
                $0.top.bottom.trailing.leading.equalToSuperview()
            }

        }
       
        navigationItem.titleView = searchTextBar

        
        searchTextBar.snp.makeConstraints {
            $0.width.equalTo(240)
            $0.height.equalTo(40)
        }
        
        
        navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.title = "채팅"
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.leftBarButtonItem?.tintColor = .black 
       
        navigationItem.rightBarButtonItem = searchBarButton
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        leftSearchIcon.tintColor = .black
        exitBarButton.tintColor = .black
    }
    
    private lazy var backBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "backIcon"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()
    
    
    private lazy var searchBarButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                                      style: .plain,
                                                      target: self,
                                                       action: nil)
    
    private lazy var exitBarButton =  UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
    
    private lazy var leftSearchIcon = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
    
    
    // MARK: Configure
    public func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.backgroundView = backgroundImageView
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        messagesCollectionView.refreshControl = refreshControl
        self.messageInputBar.inputTextView.placeholder = " 메세지를 입력해주세요."
        
    }
    private let bottomPickerBar = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
        $0.clipsToBounds = false
    }
    private let pickerLeftBtn = UIImageView().then {
        $0.image = UIImage(named: "message_search_up")
    }
    private let pickerRightBtn = UIImageView().then {
        $0.image = UIImage(named: "message_search_down")
    }
    

    
    public func configureMessageInputBar() {
        
   
        
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
        
       
        configureBottomPickerBar()
    }
    
    // MARK: - 바텀 검색 메시지 탐색 버튼 바
    public func configureBottomPickerBar() {
  
        messageInputBar.addSubview(bottomPickerBar)
    
        
        bottomPickerBar.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomPickerBar.addSubview(pickerLeftBtn)
        bottomPickerBar.addSubview(pickerRightBtn)
        
                
        pickerRightBtn.snp.makeConstraints {
            $0.trailing.top.equalToSuperview().inset(14)
            $0.width.height.equalTo(28)
        }
        pickerLeftBtn.snp.makeConstraints {
            $0.trailing.equalTo(pickerRightBtn.snp.leading).offset(-10)
            $0.top.equalTo(pickerRightBtn)
            $0.width.height.equalTo(28)

        }
      
        
    }
    
    // MARK: - EVENT
    public func messageSendfaileAlert(){
        AlertManager(viewController: self)
            .setTitle("전송실패")
            .setMessage("서버와 연결에 실패했습니다.\n잠시후에 다시 시도해주세요. ")
            .addActionConfirm("확인")
            .showCustomAlert()
    }
    
    public func searchMessageIsNotExistAlert(){
        //TODO: CustomAlert 추가 해야함.
        AlertManager.showNotExist(style: .alert, title: nil, message: "검색결과가 없습니다.")
    }
    
    //인풋바 아이탬 설정
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
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
    
    public func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    public func isNextMessageSameDate(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return areSameDates(date1: messageList[indexPath.section].sentDate, date2: messageList[indexPath.section + 1].sentDate)
    }
    
    public func areSameDates(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day && components1.minute == components2.minute
    }
    
    // MARK: - Binding
    public func setBindings() {
        
        self.moveLastBtn.rx.tapGesture().when(.recognized).subscribe({ _ in
            self.messagesCollectionView.scrollToLastItem()

        }).disposed(by: disposeBag)
        
        self.messagesCollectionView.rx.tapGesture().when(.ended)
            .subscribe(onNext: { _ in
                self.inputContainerView.endEditing(true)
                self.messageSearchTextField.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let input = ChatVM.Input(
            viewDidLoadEvent: self.viewDidLoadEvent
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            searchBtnTapEvent: self.searchBarButton.rx.tap.map({ $0 }).asObservable(),
            mySendTextMessage: self.sendTextMessage
                .asObservable(),
            mySendImageMessage: self.sendImageMessage
                .asObservable(),
            reloadMessage: self.reloadEvent
                .asObservable(),
            searchTextMessage: self.messageSearchTextField.rx.text.orEmpty.asObservable(),
            keyboardSearchBtnTapped: messageSearchTextField.rx.controlEvent(.editingDidEndOnExit).asObservable(),
            exitBarButton: self.exitBarButton.rx.tap.map({ $0 }).asObservable(),
            pickerLeftBtnTap: pickerLeftBtn.rx.tapGesture().when(.recognized).map{ _ in }.asObservable() ,
            pickerRightBtnTap: pickerRightBtn.rx.tapGesture().when(.recognized).map { _ in }.asObservable()
        )
        
        
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
          
        output.sendSuccess
            .bind(onNext: {result in
                if result {
                    
                }
                else {
                    self.messageSendfaileAlert()
                }
            })
            .disposed(by: disposeBag)
        
        output.getMessage
            .bind(onNext: { [weak self] chatMessageList in
                guard let self else {return}
                self.messageList = chatMessageList
                self.loadFirstMessages(chatMessageList)
            }).disposed(by: disposeBag)
        
        output.getMoreMessage
            .bind(onNext: { [weak self] chatMessageList in
                guard let self else {return}
                self.loadMoreMessages(chatMessageList)
            })
            .disposed(by: disposeBag)
        
        output.getRealTimeMessage
            .bind(onNext: { [weak self] chatMessageList in
                guard let self else {return}
                if self.firstLoaded {
                    chatMessageList.forEach{ chatMessage in
                        
                        self.insertOnceMessage(chatMessage)
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        // TODO: 다 돌았을때도 없을때 빈배열 넘기기 + 이미 스캔된거 다시 돌아옴 (왜??)
        output.searchedIndex.subscribe(onNext: { [weak self] searched in
            guard let self else {return}
            
            
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
                guard let firstIndex = self.messageList.firstIndex(where: {
                    
                      $0.messageId == searched.messageId
                }) else {return}
                DispatchQueue.main.async {
                  
                    
                    // MARK: - 하나씩 형광펜
//                    if let pickedCell = self.messagesCollectionView.cellForItem(at:  IndexPath(row: 0, section: firstIndex)) as? TextMessageCell {
//                     
//                        pickedCell.messageLabel.highlightText(self.testTextField.text ?? "")
//                    }
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: firstIndex), at: .centeredVertically, animated: true)
                    

                    
                    
                }
            }
          
        }).disposed(by: disposeBag)
        
        output.setChatingView.subscribe(onNext: { [weak self] in
            guard let self else {return}
            messageSearchTextField.text = ""
            
        

            
            if $0 {
                // Search 필드 ON
                navigationItem.rightBarButtonItem = exitBarButton
                navigationItem.leftBarButtonItem = leftSearchIcon
                
            } else {
                // Search 필드 OFF
                navigationItem.rightBarButtonItem = searchBarButton
                navigationItem.leftBarButtonItem = backBarButton
                
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            chatLabel.isHidden = $0
            
            messageSearchTextField.isHidden = !$0
            bottomPickerBar.isHidden = !$0
            moveLastBtn.isHidden = !$0
       
            
            
        }).disposed(by: disposeBag)
        
        output.notExistAlert.bind(onNext: searchMessageIsNotExistAlert  ).disposed(by: disposeBag)
    }
    
    
    // MARK: - Helpers
    public func insertOnceMessage(_ message: ChatModel) {
        messageList.append(message)
        print("message \(message)")
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            guard let self else {return}
            if self.isLastSectionVisible() == true {
                self.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: true)
            }
        })
    }
    
    
    public func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    public func numberOfSections(in _: MessagesCollectionView) -> Int {
        messageList.count
    }
    
    public func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        messageList[indexPath.section]
    }
    
    public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
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
    
    public func datesCompare(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
    
    public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.toString(type: .chatDate)
        if !isNextMessageSameSender(at: indexPath) {
            return NSAttributedString(
                string: dateString,
                attributes: [
                    NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.gray2
                ])
        } else if isNextMessageSameSender(at: indexPath) {
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
    public func textCell(for message: MessageType, at indexPath: IndexPath, in messageView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        //TODO: 나중에 검색창 열기 닫기로 해야될듯 -> 열어놓는 동안은 검색
        if let text = self.messageSearchTextField.text {
            cell.messageLabel.highlightText(text)
        }
        return cell
    }
    // MARK: PhotoCustomCell
    public func photoCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
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
    public func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }
    
    public func processInputBar(_ inputBar: InputBarAccessoryView) {
        // 전송 탭 시
        let components = inputBar.inputTextView.components //String
        inputBar.inputTextView.text = String() // 왜한거지
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
                
                // 뷰모델 메시지 전송
            }
        }
    }
}

// MARK: CameraInputBarAccessoryViewDelegate

extension ChatVC: CameraInputBarAccessoryViewDelegate {
    public func sendCameraImage(_ image: UIImage) {
        self.sendImageMessageEvent(photo: image)
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        
        //텍스트도 함께 입력된 경우
        if inputBar.inputTextView.text != "" {
            self.insertMessages([inputBar.inputTextView.text ?? ""])
            inputBar.inputTextView.text = ""
        }
        
        for item in attachments {
            if case .image(let image) = item {
                self.sendImageMessageEvent(photo: image)
            }
        }
    }
    
    public func downKeyboard() {
        self.inputContainerView.endEditing(true)
    }
    
    //MARK: 이미지타입 전송
    public func sendImageMessageEvent(photo: UIImage) {
        let photoMessage = ChatModel(image: photo, user: currentSender as! ChatUserModel, messageId: UUID().uuidString, date: Date())
        sendImageMessage.accept(photoMessage)
    }
    
}
