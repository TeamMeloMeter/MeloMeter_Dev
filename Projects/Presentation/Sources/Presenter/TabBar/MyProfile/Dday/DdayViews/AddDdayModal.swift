//
//  AddDdayViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Domain
import Data
import Core

public class AddDdayModal: UIViewController, UITextFieldDelegate {
    
    public var viewModel: DdayVM?
    private let disposeBag = DisposeBag()
    
    public init(viewModel: DdayVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextView.delegate = self
        self.dateTextField.delegate = self
        configure()
        setAutoLayout()
        setBindings()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressDialogView.shared.hide()
    }
    // MARK: Bindings
    public func setBindings() {
        self.view.rx.tapGesture().when(.ended)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let input = DdayVM.AddDdayInput(
            xBtnTapEvent: xButton.rx.tap
                .map({ _ in })
                .asObservable(),
            addDday: saveButton.rx.tap
                .map({ _ in
                    ProgressDialogView.shared.show()
                    self.dateTextField.endEditing(true)
                    if let title = self.titleTextView.text, let date = self.dateTextField.text {
                        guard title != "" && date != "" else{
                            self.inputError()
                            return []
                        }
                        ProgressDialogView.shared.hide()
                        return [title, date]
                    }
                    return []
                })
                .asObservable()
        )
        
        self.viewModel?.addDdayBinding(input: input, disposeBag: self.disposeBag)
        
        self.dateTextField.rx.controlEvent(.editingDidBegin)
            .map({ _ in })
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.saveButton.isEnabled = true
                self.saveButton.alpha = 1.0
                self.saveButton.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
                self.datePicker.rx.date
                    .map{ date in
                        return date.toString(type: .yearAndMonthAndDate)
                    }
                    .bind(to: self.dateTextField.rx.text)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }

    // MARK: Event
    
    public func inputError() {
        AlertManager(viewController: self)
            .setTitle("추가 실패")
            .setMessage("제목과 날짜를\n모두 입력해주세요!")
            .addActionConfirm("확인",
                              action: { self.titleTextView.becomeFirstResponder() }
            )
            .showCustomAlert()
        ProgressDialogView.shared.hide()
    }

    
    
    // MARK: UI
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9813271165, green: 0.9813271165, blue: 0.9813271165, alpha: 1)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.addSubview(topLabel)
        view.addSubview(xButton)
        view.addSubview(titleLabel)
        view.addSubview(titleTextView)
        view.addSubview(textPlaceHolderLabel)
        view.addSubview(textCountLabel)
        view.addSubview(dateTextField)
        view.addSubview(dateTitleLabel)
        return view
    }()
    
    // 반투명 배경
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    //창닫기버튼
    public let xButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "xmark"), for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        return button
    }()
    
    //상단 타이틀 label
    private let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "새로운 일정 추가"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    // "제목" label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray2
        label.text = "제목"
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    // 제목 입력
    public var titleTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .gray5
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.keyboardType = .default
        tv.becomeFirstResponder()
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 9, bottom: 15, right: 15)
        tv.tintColor = .gray1
        tv.layer.cornerRadius = 8
        tv.clipsToBounds = true
        return tv
    }()
    
    //텍스트뷰 플레이스홀더 label
    public let textPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray3
        label.text = "어떤 이벤트인가요?"
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    public var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    // 날짜
    lazy var dateTextField: UITextField = {
        let tv = UITextField()
        // 플레이스홀더에 표시할 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray3,
            .font: FontManager.shared.medium(ofSize: 16)
        ]
        tv.backgroundColor = .gray5
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.attributedPlaceholder = NSAttributedString(string: "날짜를 선택해주세요", attributes: attributes)
        tv.tintColor = .gray1
        tv.inputView = datePicker
        tv.inputAccessoryView = dateInputView
        tv.addLeftPadding()
        tv.layer.cornerRadius = 8
        tv.clipsToBounds = true
        return tv
    }()
    
    //날짜 textField inputView
    lazy var dateInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(saveButton)
        
        return view
    }()
    
    // 저장버튼
    public let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    //datePicker
    public let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.backgroundColor = UIColor.white
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        return datePicker
    }()
    
    private let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray2
        label.text = "날짜"
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure() {
        view.backgroundColor = .clear
        [dimmedView, containerView].forEach { view.addSubview($0) }
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        dimmedViewConstraints()
        containerViewConstraints()
        topLabelConstraints()
        xButtonConstraints()
        titleLabelConstraints()
        titleTextViewConstraints()
        dateViewConstraints()
        dateInputViewConstraints()
    }
    
    private func dimmedViewConstraints() {
        dimmedView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
    }
    
    private func containerViewConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 616)
        ])
    }
    
    private func xButtonConstraints() {
        xButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            xButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            xButton.widthAnchor.constraint(equalToConstant: 48),
            xButton.heightAnchor.constraint(equalToConstant: 48)

        ])
    }
    
    private func topLabelConstraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            topLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32)
        ])
    }
    
    private func titleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 31)
        ])
    }
    
    private func titleTextViewConstraints() {
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        textPlaceHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        textCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 125),
            titleTextView.widthAnchor.constraint(equalToConstant: 343),
            titleTextView.heightAnchor.constraint(equalToConstant: 50),
            
            textPlaceHolderLabel.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor, constant: 13),
            textPlaceHolderLabel.topAnchor.constraint(equalTo: titleTextView.topAnchor, constant: 16),

            textCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textCountLabel.bottomAnchor.constraint(equalTo: titleTextView.topAnchor, constant: -20)
        ])
    }
    
    private func dateViewConstraints() {
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            dateTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            dateTextField.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 61),
            dateTextField.widthAnchor.constraint(equalToConstant: 343),
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            dateTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateTitleLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 27),

        ])
    }

    public func dateInputViewConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            saveButton.leadingAnchor.constraint(equalTo: dateInputView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: dateInputView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 52)

        ])
    }
}

extension AddDdayModal: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        self.textPlaceHolderLabel.isHidden = !textView.text.isEmpty
        self.textCountLabel.text = "\(self.titleTextView.text.count)/10"
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 10
    }
    
}
