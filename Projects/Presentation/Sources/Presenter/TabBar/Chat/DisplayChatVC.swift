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
import RxSwift
import RxGesture
import Domain
import Data
import Core
// MARK: - BasicExampleViewController

public final class DisplayChatVC: ChatVC {
    
    private let viewModel: ChatVM?
    private var noticeViewHeight: NSLayoutConstraint!
    public var otherProfileImage = UIImage(named: "defaultProfileImage")!
    public var downBtnToggle = false
    override init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: Bindings
    public func setBinding() {
        self.downBtn.rx.tap
            .subscribe(onNext: { _ in
                if self.downBtnToggle {
                    self.downBtnToggle = false
                    self.noticeUp()
                }else {
                    self.downBtnToggle = true
                    self.noticeDown()
                }
                
            })
            .disposed(by: disposeBag)
        
        let input = ChatVM.DisplayInput(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            lastAnswerBtnTapEvent: self.lastAnswerBtn.rx.tap
                .map({ _ in })
                .asObservable(),
            goAnswerBtnTapEvent: self.goAnswerBtn.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        guard let output = self.viewModel?.noticeTransform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.otherProfileImage
            .bind(onNext: {[weak self] image in
                self?.otherProfileImage = image
                self?.messagesCollectionView.scrollToLastItem(at: .centeredVertically, animated: true)
                self?.messagesCollectionView.reloadData()
                self?.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        output.questionComplete
            .bind(onNext: { text in
                self.alarmLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.questionText
            .bind(onNext: { text in
                self.questionLabel.text = text
            })
            .disposed(by: disposeBag)
        
        
    }
    
    // MARK: Event
    public func noticeDown() {
        self.noticeView.removeConstraint(self.noticeViewHeight)
        self.noticeView.translatesAutoresizingMaskIntoConstraints = false
        self.noticeViewHeight = self.noticeView.heightAnchor.constraint(equalToConstant: 170)
        self.noticeViewHeight.isActive = true
        
        self.noticeView.alpha = 0.9
        self.qLabel.isHidden = false
        self.questionLabel.isHidden = false
        self.lastAnswerBtn.isHidden = false
        self.goAnswerBtn.isHidden = false
        self.lineView.isHidden = false
        
        self.view.layoutIfNeeded()
        
    }
    public func noticeUp() {
        self.qLabel.isHidden = true
        self.questionLabel.isHidden = true
        self.lastAnswerBtn.isHidden = true
        self.goAnswerBtn.isHidden = true
        self.lineView.isHidden = true
        if self.noticeViewHeight != nil {
            self.noticeView.removeConstraint(self.noticeViewHeight)
        }
        self.noticeView.translatesAutoresizingMaskIntoConstraints = false
        self.noticeViewHeight = self.noticeView.heightAnchor.constraint(equalToConstant: 48)
        self.noticeViewHeight.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.noticeView.backgroundColor = .white
            self.noticeView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    public func showCameraAlert() -> Single<CameraAlert> {
        return AlertManager(viewController: self)
            .showCameraAlert()
    }
    
    // MARK: Configure
    public func configure() {
        [noticeView, letterImageView, alarmLabel, downBtn].forEach { view.addSubview($0) }
        self.noticeUp()
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = CGSize(width: 35, height: 35)
            
            layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: self.view.frame.width / 3, bottom: 0, right: 10))
            layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: self.view.frame.width / 3))
            
            layout.textMessageSizeCalculator.incomingAvatarPosition.vertical = .messageTop
            layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets.left = 6
            layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets.right = 6
            
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = CGSize(width: 35, height: 35)
            layout.photoMessageSizeCalculator.incomingAvatarPosition.vertical = .messageTop
            layout.photoMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets.left = 6
            layout.photoMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets.right = 6
        }
    }
    public override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.register(CustomMessageCell.self, forCellWithReuseIdentifier: "CustomMessageCell")
        messagesCollectionView.register(CustomPhotoCell.self, forCellWithReuseIdentifier: "CustomPhotoCell")
        messagesCollectionView.scrollToLastItem()
        configure()
        setBinding()
        setAutoLayout()
    }
    
    // MARK: UI
    lazy var noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.applyShadow(color: #colorLiteral(red: 0.6070454717, green: 0.6070454121, blue: 0.6070454121, alpha: 1), alpha: 0.25, x: 2, y: 2, blur: 15)
        view.alpha = 0.9
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        [lineView, qLabel, questionLabel, goAnswerBtn, lastAnswerBtn].forEach { view.addSubview($0) }
        return view
    }()
    
    public let letterImageView = UIImageView(image: UIImage(named: "hundredQA"))
    
    public let alarmLabel: UILabel = {
        let label = UILabel()
        label.text = "백문백답질문도착"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    public let downBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "downBtn"), for: .normal)
        return button
    }()
    
    public let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.997919023, green: 0.828189075, blue: 0.9971280694, alpha: 1)
        return view
    }()
    
    public let qLabel: UILabel = {
        let label = UILabel()
        label.text = "Q."
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 16)
        return label
    }()
    
    public let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "질문 내용"
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 15)
        return label
    }()
    
    public let lastAnswerBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("지난 답변 확인", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.titleLabel?.font = FontManager.shared.regular(ofSize: 14)
        button.layer.cornerRadius = 8
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.26, x: 0, y: 0, blur: 6)
        button.layer.masksToBounds = false
        return button
    }()
    
    public let goAnswerBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("답변하러가기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.titleLabel?.font = FontManager.shared.regular(ofSize: 14)
        button.layer.cornerRadius = 8
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.26, x: 0, y: 0, blur: 6)
        button.layer.masksToBounds = false
        return button
    }()
    
    // MARK: 오토레이아웃
    public func setAutoLayout() {
        noticeView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(9)
        }
        
        letterImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.width.equalTo(20)
            $0.height.equalTo(18)
        }
        
        alarmLabel.snp.makeConstraints {
            $0.leading.equalTo(letterImageView.snp.trailing).offset(16)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(23)
            $0.height.equalTo(21)
        }
        
        downBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-17)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(9)
            $0.width.height.equalTo(48)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(noticeView.snp.top).offset(48)
            $0.centerX.equalTo(noticeView)
            $0.width.equalTo(308)
            $0.height.equalTo(1)
        }
        
        qLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(22)
            $0.leading.equalTo(noticeView).offset(18)
            $0.height.equalTo(22)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(22)
            $0.leading.equalTo(qLabel.snp.trailing).offset(18)
            $0.height.equalTo(22)
        }
        
        lastAnswerBtn.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(24)
            $0.leading.equalTo(noticeView).offset(18)
            $0.width.equalTo(150)
            $0.height.equalTo(38)
        }
        
        goAnswerBtn.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(24)
            $0.trailing.equalTo(noticeView).offset(-18)
            $0.width.equalTo(150)
            $0.height.equalTo(38)
        }
    }

}

// MARK: MessagesDisplayDelegate

extension DisplayChatVC: MessagesDisplayDelegate {
    // MARK: - Text Messages
    public func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .gray1 : .gray1
    }
    
    public func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    public func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages
    public func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? UIColor.primary1.withAlphaComponent(0.22) : .white
    }
    
    
    public func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        var corners: UIRectCorner = []
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.topRight)
            corners.formUnion(.bottomLeft)
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            corners.formUnion(.bottomLeft)
        }
        
        return .custom { view in
            let radius: CGFloat = 12
            let path = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    public func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in _: MessagesCollectionView)
    {
        let avatar = Avatar(image: self.otherProfileImage, initials: "연인")
        
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
        }else {
            avatarView.set(avatar: avatar)
            avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
        }
        
    }
    
    public func configureMediaMessageImageView(
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

}

// MARK: MessagesLayoutDelegate

extension DisplayChatVC: MessagesLayoutDelegate {
    
    // 아래 여백
    public func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if section == messageList.count - 1 {
            return CGSize(width: 0, height: 20)
        }
        return CGSize(width: 0, height: 0)
    }
    
    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        guard super.messageList.last != nil else{ return 0 }
        
        if indexPath.section - 1 > 0{
            if !datesCompare(date1: messageList[indexPath.section - 1].sentDate, date2: message.sentDate){
                return 44
            }
        }
        return 0
    }
    
    public func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !isPreviousMessageSameSender(at: indexPath) {
            return 32
        }
        return 0
    }
    
    public func messageBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        return nil
    }
    
    
}
