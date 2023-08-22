//
//  AnswerVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa

class ReadAnswerVC: UIViewController {
    
    private let viewModel: AnswerVM?
    let disposeBag = DisposeBag()
    
    init(viewModel: AnswerVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setBindings() {
        
        let input = AnswerVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            answerBtnTapEvent: self.answerBtn.rx.tap
                .map({ _ in
                    return (.goAnswer, [self.questionLabel.text ?? "", "소희"])
                })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
       
        
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        setNavigationBar()
        [questionView,
         otherUserView,
         myUserView].forEach { view.addSubview($0) }
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
        label.text = "제일 좋아하는 데이트 장소는 어디인가요?"
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
    
    private let otherUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "제훈님의 답변"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    let lineView1: UIView = {
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
    
    let otherAnswerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "안녕하세요. 답변입니다 \n\n 100글자를 채워 보겠 습니 다 \n\n ㅡㅡㅡㅡㅡㅡㅡ100자가 얼만큼 일까요\nㅇㄹ롿ㅈㅇ롸지로ㅓ지ㅏ로ㅓㅣㄹ오다ㅑㅓㅜㅚ"
        label.textColor = .gray1
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

        return view
    }()
    
    private let myUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "소희님의 답변"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    let lineView2: UIView = {
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
        scView.addSubview(answerBtn)
        return scView
    }()
    
    let myAnswerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "서로의 생각을 확인하고 싶다면\n백문백답을 답변해주세요!"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        return label
    }()
    
    let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "lockImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let answerBtn: UIButton = {
        let button = UIButton()
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
        questionView.translatesAutoresizingMaskIntoConstraints = false
        questionImageView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        otherUserView.translatesAutoresizingMaskIntoConstraints = false
        otherAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        otherScrollView.translatesAutoresizingMaskIntoConstraints = false
        otherUserLabel.translatesAutoresizingMaskIntoConstraints = false

        myUserView.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        myUserLabel.translatesAutoresizingMaskIntoConstraints = false
        myScrollView.translatesAutoresizingMaskIntoConstraints = false
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        myAnswerLabel.translatesAutoresizingMaskIntoConstraints = false

        answerBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            questionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 28),
            questionView.heightAnchor.constraint(equalToConstant: 48),

            questionImageView.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 14),
            questionImageView.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),
            questionImageView.widthAnchor.constraint(equalToConstant: 20),
            questionImageView.heightAnchor.constraint(equalToConstant: 18),
            
            questionLabel.leadingAnchor.constraint(equalTo: questionImageView.trailingAnchor, constant: 14),
            questionLabel.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),

            otherUserView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 27),
            otherUserView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            otherUserView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            otherUserView.heightAnchor.constraint(equalToConstant: 158),

            otherUserLabel.topAnchor.constraint(equalTo: otherUserView.topAnchor, constant: 18),
            otherUserLabel.leadingAnchor.constraint(equalTo: otherUserView.leadingAnchor, constant: 17),

            lineView1.topAnchor.constraint(equalTo: otherUserLabel.bottomAnchor, constant: 8),
            lineView1.centerXAnchor.constraint(equalTo: otherUserView.centerXAnchor),
            lineView1.widthAnchor.constraint(equalToConstant: 308),
            lineView1.heightAnchor.constraint(equalToConstant: 1),

            otherScrollView.topAnchor.constraint(equalTo: lineView1.bottomAnchor),
            otherScrollView.widthAnchor.constraint(equalTo: otherUserView.widthAnchor),
            otherScrollView.centerXAnchor.constraint(equalTo: otherUserView.centerXAnchor),
            otherScrollView.bottomAnchor.constraint(equalTo: otherUserView.bottomAnchor),
       
            otherAnswerLabel.leadingAnchor.constraint(equalTo: otherScrollView.leadingAnchor, constant: 17),
            otherAnswerLabel.topAnchor.constraint(equalTo: otherScrollView.topAnchor, constant: 17),
            otherAnswerLabel.trailingAnchor.constraint(equalTo: otherScrollView.trailingAnchor, constant: -17),
            otherAnswerLabel.bottomAnchor.constraint(equalTo: otherScrollView.bottomAnchor, constant: -5),

            myUserView.topAnchor.constraint(equalTo: otherUserView.bottomAnchor, constant: 26),
            myUserView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            myUserView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            myUserView.heightAnchor.constraint(equalToConstant: 359),

            myUserLabel.topAnchor.constraint(equalTo: myUserView.topAnchor, constant: 18),
            myUserLabel.leadingAnchor.constraint(equalTo: myUserView.leadingAnchor, constant: 17),

            lineView2.topAnchor.constraint(equalTo: myUserLabel.bottomAnchor, constant: 8),
            lineView2.centerXAnchor.constraint(equalTo: myUserView.centerXAnchor),
            lineView2.widthAnchor.constraint(equalToConstant: 308),
            lineView2.heightAnchor.constraint(equalToConstant: 1),

            myScrollView.topAnchor.constraint(equalTo: lineView2.bottomAnchor),
            myScrollView.widthAnchor.constraint(equalTo: myUserView.widthAnchor),
            myScrollView.centerXAnchor.constraint(equalTo: myUserView.centerXAnchor),
            myScrollView.bottomAnchor.constraint(equalTo: myUserView.bottomAnchor),
       
            myAnswerLabel.leadingAnchor.constraint(equalTo: myScrollView.leadingAnchor, constant: 17),
            myAnswerLabel.topAnchor.constraint(equalTo: myScrollView.topAnchor, constant: 17),
            myAnswerLabel.trailingAnchor.constraint(equalTo: myScrollView.trailingAnchor, constant: -17),
            
            lockImageView.centerXAnchor.constraint(equalTo: myScrollView.centerXAnchor),
            lockImageView.topAnchor.constraint(equalTo: myAnswerLabel.bottomAnchor, constant: 20),
            lockImageView.widthAnchor.constraint(equalToConstant: 309),
            lockImageView.heightAnchor.constraint(equalToConstant: 131),

            answerBtn.centerXAnchor.constraint(equalTo: myUserView.centerXAnchor),
            answerBtn.widthAnchor.constraint(equalToConstant: 320),
            answerBtn.heightAnchor.constraint(equalToConstant: 48),
            answerBtn.topAnchor.constraint(equalTo: lockImageView.bottomAnchor, constant: 20),

        ])
    }
    
}

