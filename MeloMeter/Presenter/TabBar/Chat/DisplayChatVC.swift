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
// MARK: - BasicExampleViewController

final class DisplayChatVC: ChatVC {
    
    private let viewModel: ChatVM?
    private var noticeViewHeight: NSLayoutConstraint!
    var otherProfileImage = UIImage(named: "defaultProfileImage")!
    var downBtnToggle = false
    override init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: Bindings
    func setBinding() {
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
    func noticeDown() {
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
    func noticeUp() {
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
    func showCameraAlert() -> Single<CameraAlert> {
        return AlertManager(viewController: self)
            .showCameraAlert()
    }
    
    // MARK: Configure
    func configure() {
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
    override func configureMessageCollectionView() {
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
    
    let letterImageView = UIImageView(image: UIImage(named: "hundredQA"))
    
    let alarmLabel: UILabel = {
        let label = UILabel()
        label.text = "백문백답질문도착"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    let downBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "downBtn"), for: .normal)
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.997919023, green: 0.828189075, blue: 0.9971280694, alpha: 1)
        return view
    }()
    
    let qLabel: UILabel = {
        let label = UILabel()
        label.text = "Q."
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 16)
        return label
    }()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "질문 내용"
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 15)
        return label
    }()
    
    let lastAnswerBtn: UIButton = {
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
    
    let goAnswerBtn: UIButton = {
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
    func setAutoLayout() {
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        letterImageView.translatesAutoresizingMaskIntoConstraints = false
        alarmLabel.translatesAutoresizingMaskIntoConstraints = false
        downBtn.translatesAutoresizingMaskIntoConstraints = false
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        qLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        lastAnswerBtn.translatesAutoresizingMaskIntoConstraints = false
        goAnswerBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            noticeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            noticeView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 9),
            
            letterImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            letterImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 24),
            letterImageView.widthAnchor.constraint(equalToConstant: 20),
            letterImageView.heightAnchor.constraint(equalToConstant: 18),
            
            alarmLabel.leadingAnchor.constraint(equalTo: letterImageView.trailingAnchor, constant: 16),
            alarmLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 23),
            alarmLabel.heightAnchor.constraint(equalToConstant: 21),
            
            downBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -17),
            downBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 9),
            downBtn.widthAnchor.constraint(equalToConstant: 48),
            downBtn.heightAnchor.constraint(equalToConstant: 48),
            
            lineView.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 48),
            lineView.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 308),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            qLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
            qLabel.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor, constant: 18),
            qLabel.heightAnchor.constraint(equalToConstant: 22),
            
            questionLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
            questionLabel.leadingAnchor.constraint(equalTo: qLabel.trailingAnchor, constant: 18),
            questionLabel.heightAnchor.constraint(equalToConstant: 22),
            
            lastAnswerBtn.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            lastAnswerBtn.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor, constant: 18),
            lastAnswerBtn.widthAnchor.constraint(equalToConstant: 150),
            lastAnswerBtn.heightAnchor.constraint(equalToConstant: 38),
            
            goAnswerBtn.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            goAnswerBtn.leadingAnchor.constraint(equalTo: lastAnswerBtn.trailingAnchor, constant: 7),
            goAnswerBtn.widthAnchor.constraint(equalToConstant: 150),
            goAnswerBtn.heightAnchor.constraint(equalToConstant: 38),
        ])
    }
}

// MARK: MessagesDisplayDelegate

extension DisplayChatVC: MessagesDisplayDelegate {
    // MARK: - Text Messages
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .gray1 : .gray1
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
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
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
    
    func configureAvatarView(
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

}

// MARK: MessagesLayoutDelegate

extension DisplayChatVC: MessagesLayoutDelegate {
    
    // 아래 여백
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if section == messageList.count - 1 {
            return CGSize(width: 0, height: 20)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        guard super.messageList.last != nil else{ return 0 }
        
        if indexPath.section - 1 > 0{
            if !datesCompare(date1: messageList[indexPath.section - 1].sentDate, date2: message.sentDate){
                return 44
            }
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !isPreviousMessageSameSender(at: indexPath) {
            return 32
        }
        return 0
    }
    
    func messageBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        return nil
    }
    
    
}

