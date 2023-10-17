//
//  WriteAnswerVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa

class WriteAnswerVC: UIViewController {
    
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
        self.answerTextView.becomeFirstResponder()
    }
    
    func setBindings() {
        
        let input = AnswerVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            answerBtnTapEvent: nil,
            answerInputText:  self.completeButton.rx.tap
                .map({ _ in
                    return self.answerTextView.text ?? ""
                })
                .asObservable()
        )
        
        guard let output = self.viewModel?.writeTransform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.questionText
            .subscribe(onNext: { text in
                self.questionLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.myName
            .subscribe(onNext: { text in
                self.myUserLabel.text = "\(text)님의 답변"
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        setNavigationBar()
        [questionView,
         answerView,
         textPlaceHolderLabel].forEach { view.addSubview($0) }
        answerTextView.delegate = self
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "백문백답"
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private lazy var backBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "backIcon"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()
    
    private lazy var completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "등록",
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

    lazy var answerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.6070454717, green: 0.6070454121, blue: 0.6070454121, alpha: 1), alpha: 0.1, x: 0, y: 1, blur: 10)
        view.addSubview(myUserLabel)
        view.addSubview(lineView)
        view.addSubview(answerTextView)
        view.addSubview(textCountLabel)
        return view
    }()
    
    private let myUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.997919023, green: 0.828189075, blue: 0.9971280694, alpha: 1)
        return view
    }()
    
    var answerTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .white
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 15)
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.keyboardType = .default
        tv.becomeFirstResponder()
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 9, bottom: 15, right: 15)
        tv.tintColor = .gray1
        return tv
    }()
    
    let textPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray3
        label.font = FontManager.shared.medium(ofSize: 15)
        return label
    }()
    
    var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/100"
        label.font = FontManager.shared.medium(ofSize: 13)
        label.textColor = .gray2
        return label
    }()
    
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        questionView.translatesAutoresizingMaskIntoConstraints = false
        questionImageView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        answerView.translatesAutoresizingMaskIntoConstraints = false
        myUserLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTextView.translatesAutoresizingMaskIntoConstraints = false
        textCountLabel.translatesAutoresizingMaskIntoConstraints = false
        textPlaceHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            questionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 28),
            questionView.heightAnchor.constraint(equalToConstant: 48),

            questionImageView.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 12),
            questionImageView.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),
            questionImageView.widthAnchor.constraint(equalToConstant: 20),
            questionImageView.heightAnchor.constraint(equalToConstant: 18),
            
            questionLabel.leadingAnchor.constraint(equalTo: questionImageView.trailingAnchor, constant: 14),
            questionLabel.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),

            answerView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 27),
            answerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            answerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            answerView.heightAnchor.constraint(equalToConstant: 158),

            myUserLabel.topAnchor.constraint(equalTo: answerView.topAnchor, constant: 18),
            myUserLabel.leadingAnchor.constraint(equalTo: answerView.leadingAnchor, constant: 17),
            myUserLabel.heightAnchor.constraint(equalToConstant: 28),

            textCountLabel.topAnchor.constraint(equalTo: answerView.topAnchor, constant: 24),
            textCountLabel.trailingAnchor.constraint(equalTo: answerView.trailingAnchor, constant: -16),

            lineView.topAnchor.constraint(equalTo: myUserLabel.bottomAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: answerView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: answerView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 1),

            answerTextView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 17),
            answerTextView.centerXAnchor.constraint(equalTo: answerView.centerXAnchor),
            answerTextView.widthAnchor.constraint(equalToConstant: 308),
            answerTextView.bottomAnchor.constraint(equalTo: answerView.bottomAnchor),

            textPlaceHolderLabel.leadingAnchor.constraint(equalTo: answerTextView.leadingAnchor, constant: 13),
            textPlaceHolderLabel.topAnchor.constraint(equalTo: answerTextView.topAnchor, constant: 16),
        
        ])
    }
    
}

extension WriteAnswerVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.textPlaceHolderLabel.isHidden = !textView.text.isEmpty
        self.textCountLabel.text = "\(self.answerTextView.text.count)/100"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
    
}
