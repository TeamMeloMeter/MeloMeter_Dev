//
//  AnswerVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa
import CoreImage
import Domain
import Data
import Core
public class ReadAnswerVC: UIViewController {


    
    private let viewModel: AnswerVM?
    private let disposeBag = DisposeBag()
    private var userName = ""
    private var otherUserName = ""
    
    public init(viewModel: AnswerVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func setBindings() {
        
        let input = AnswerVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            answerBtnTapEvent: self.answerBtn.rx.tap
                .map({ _ in })
                .asObservable(),
            answerInputText: nil
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.questionText
            .subscribe(onNext: { text in
                self.questionLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.myAnswerInfo
            .subscribe(onNext: {[weak self] info in
                guard let self = self else{ return }
                self.myUserLabel.text = "\(info.userName)님의 답변"
                self.userName = info.userName
                if info.answerText.isEmpty {
                    self.myAnswerLabel.text = "서로의 생각을 확인하고 싶다면\n백문백답을 답변해주세요!"
                }else {
                    self.myAnswerLabel.text = info.answerText
                }
            })
            .disposed(by: disposeBag)
        
        output.otherAnswerInfo
            .subscribe(onNext: {[weak self] info in
                guard let self = self else{ return }
                self.otherUserLabel.text = "\(info.userName)님의 답변"
                self.otherUserName = info.userName
                if info.answerText.isEmpty {
                    self.otherAnswerLabel.text = "\(info.userName)님이 아직 답변하지 않으셨어요!"
                }else {
                    self.otherAnswerLabel.text = info.answerText
                }
            })
            .disposed(by: disposeBag)
       
        output.isAnswers
            .subscribe(onNext: {[weak self] isAnswers in
                self?.isAnswer(mine: isAnswers[0], other: isAnswers[1])
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: Event
    public func isAnswer(mine: Bool, other: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let attributedText = NSMutableAttributedString(string: self.myAnswerLabel.text ?? "")
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        self.myAnswerLabel.attributedText = attributedText
        if mine && other { //둘다 답변
            self.myUserView.heightAnchor.constraint(equalToConstant: 133).isActive = true
            self.lockImageView.isHidden = true
            self.unlockImageView.isHidden = false
            self.myAnswerCompleteLabel.isHidden = true
            self.answerBtn.isHidden = true
            self.otherAnswerLabel.textColor = .gray1
            return
        }
        
        self.unlockImageView.isHidden = true
        self.lockImageView.isHidden = false
        self.myUserView.heightAnchor.constraint(equalToConstant: 359).isActive = true

        if !mine && other { // 상대만 답변
            self.otherAnswerLabel.textColor = .gray1
            self.lockImageView.image = UIImage(named: "lockImage")
            self.answerBtn.isHidden = false
            self.myAnswerCompleteLabel.isHidden = true
            self.otherAnswerLabel.text = "\(self.otherUserName)님이 답변을 완료했습니다."
            return
        }
        
        if mine && !other { // 나만 답변
            self.myUserView.heightAnchor.constraint(equalToConstant: 347).isActive = true
            self.lockImageView.image = UIImage(named: "unlockImage")
            self.answerBtn.isHidden = true
            self.myAnswerCompleteLabel.isHidden = false
            self.otherAnswerLabel.textColor = .gray3
        }
       
        if !mine && !other { // 둘다안함
            self.answerBtn.isHidden = false
            self.lockImageView.image = UIImage(named: "lockImage")
            self.myAnswerCompleteLabel.isHidden = true
            self.otherAnswerLabel.textColor = .gray3
        }
    }
    
    
    // MARK: Configure
    public func configure() {
        view.backgroundColor = .white
        setNavigationBar()
        [questionView,
         otherUserView,
         myUserView,
         unlockImageView].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "백문백답"
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
    
    // MARK: UI
    lazy var questionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.6070454717, green: 0.6070454121, blue: 0.6070454121, alpha: 1), alpha: 0.1, x: 0, y: 1, blur: 10)
        view.addSubview(questionLabel)
        view.addSubview(questionImageView)
        
        return view
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primary1
        label.font = FontManager.shared.bold(ofSize: 16)
        return label
    }()
    
    private let questionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hundredQA")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var otherUserView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.6070454717, green: 0.6070454121, blue: 0.6070454121, alpha: 1), alpha: 0.1, x: 0, y: 1, blur: 10)
        view.addSubview(otherUserLabel)
        view.addSubview(lineView1)
        view.addSubview(otherScrollView)

        return view
    }()
    
    public let otherUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    public let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.997919023, green: 0.828189075, blue: 0.9971280694, alpha: 1)
        return view
    }()
    
    lazy var otherScrollView: UIScrollView = {
        let scView = UIScrollView()
        scView.backgroundColor = .white
        scView.indicatorStyle = .black
        scView.addSubview(otherAnswerLabel)
        return scView
    }()
    
    public let otherAnswerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.textColor = .gray3
        label.font = FontManager.shared.medium(ofSize: 15)
        return label
    }()
    
    lazy var myUserView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.6070454717, green: 0.6070454121, blue: 0.6070454121, alpha: 1), alpha: 0.1, x: 0, y: 1, blur: 10)
        view.addSubview(myUserLabel)
        view.addSubview(lineView2)
        view.addSubview(myScrollView)
        view.addSubview(answerBtn)
        return view
    }()
    
    private let myUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    public let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.997919023, green: 0.828189075, blue: 0.9971280694, alpha: 1)
        return view
    }()
    
    lazy var myScrollView: UIScrollView = {
        let scView = UIScrollView()
        scView.backgroundColor = .white
        scView.indicatorStyle = .black
        scView.addSubview(myAnswerLabel)
        scView.addSubview(lockImageView)
        scView.addSubview(myAnswerCompleteLabel)
        return scView
    }()
    
    public let myAnswerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 26
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        return label
    }()
    
    public let myAnswerCompleteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "답변 완료!\n상대방은 어떻게 생각할까요? 물어봐 주세요!"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        return label
    }()
    
    public let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = UIImage(named: "lockImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let unlockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = UIImage(named: "completeImage")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.applyShadow(color: #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1), alpha: 0.25, x: 0, y: 2, blur: 8)
        return imageView
    }()
    
    public let answerBtn: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.backgroundColor = .white
        button.setTitle("답변하기", for: .normal)
        button.setTitleColor(.primary1, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 16)
        button.layer.cornerRadius = 25
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.3, x: 0, y: 0, blur: 10)
        button.layer.masksToBounds = false
        return button
    }()
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        questionView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            $0.height.equalTo(48)
        }

        questionImageView.snp.makeConstraints {
            $0.leading.equalTo(questionView).offset(14)
            $0.centerY.equalTo(questionView)
            $0.width.equalTo(20)
            $0.height.equalTo(18)
        }

        questionLabel.snp.makeConstraints {
            $0.leading.equalTo(questionImageView.snp.trailing).offset(12)
            $0.centerY.equalTo(questionView)
        }

        otherUserView.snp.makeConstraints {
            $0.top.equalTo(questionView.snp.bottom).offset(27)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(158)
        }

        otherUserLabel.snp.makeConstraints {
            $0.top.equalTo(otherUserView).offset(18)
            $0.leading.equalTo(otherUserView).offset(17)
        }

        lineView1.snp.makeConstraints {
            $0.top.equalTo(otherUserLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(otherUserView).inset(16)
            $0.height.equalTo(1)
        }

        otherScrollView.snp.makeConstraints {
            $0.top.equalTo(lineView1.snp.bottom)
            $0.width.equalTo(otherUserView)
            $0.centerX.equalTo(otherUserView)
            $0.bottom.equalTo(otherUserView)
        }

        otherAnswerLabel.snp.makeConstraints {
            $0.top.equalTo(otherScrollView).offset(17)
            $0.leading.equalTo(otherScrollView).offset(17)
            $0.trailing.equalTo(otherScrollView).inset(17)
            $0.bottom.equalTo(otherScrollView).inset(5)
        }

        myUserView.snp.makeConstraints {
            $0.top.equalTo(otherUserView.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        myUserLabel.snp.makeConstraints {
            $0.top.equalTo(myUserView).offset(18)
            $0.leading.equalTo(myUserView).offset(17)
        }

        lineView2.snp.makeConstraints {
            $0.top.equalTo(myUserLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(otherUserView).inset(16)
            $0.height.equalTo(1)
        }

        myScrollView.snp.makeConstraints {
            $0.top.equalTo(lineView2.snp.bottom)
            $0.width.equalTo(lineView2)
            $0.centerX.equalTo(myUserView)
            $0.bottom.equalTo(myUserView).inset(5)
        }

        myAnswerLabel.snp.makeConstraints {
            $0.top.equalTo(myScrollView).offset(17)
            $0.leading.equalTo(myScrollView)
            $0.trailing.equalTo(myScrollView)
        }

        lockImageView.snp.makeConstraints {
            $0.leading.trailing.equalTo(myUserView)
            $0.top.equalTo(myAnswerLabel.snp.bottom).offset(23)
            $0.height.equalTo(131)
        }

        answerBtn.snp.makeConstraints {
            $0.centerX.equalTo(myUserView)
            $0.width.equalTo(320)
            $0.height.equalTo(48)
            $0.top.equalTo(lockImageView.snp.bottom).offset(25)
        }

        myAnswerCompleteLabel.snp.makeConstraints {
            $0.top.equalTo(lockImageView.snp.bottom).offset(20)
            $0.bottom.equalTo(myScrollView).inset(30)
            $0.centerX.equalTo(lockImageView)
            $0.width.equalTo(308)
            $0.height.equalTo(53)
        }

        unlockImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(myUserView.snp.bottom).offset(24)
            $0.height.equalTo(131)
        }

    }
    
}
