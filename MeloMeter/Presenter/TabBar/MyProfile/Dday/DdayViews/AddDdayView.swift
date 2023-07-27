//
//  AddDdayView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit
// 기념일 추가 뷰
class AddDdayView: UIView {
    
    // 표시 modal
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
    let xButton: UIButton = {
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
    var titleTextView: UITextView = {
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
        return tv
    }()
    
    //텍스트뷰 플레이스홀더 label
    let textPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray3
        label.text = "어떤 이벤트인가요?"
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    var textCountLabel: UILabel = {
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
        return tv
    }()
    
    //날짜 textField inputView
    lazy var dateInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(saveButton)
        
        return view
    }()
    
    // 저장버튼
    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    //datePicker
    let datePicker: UIDatePicker = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        dateInputViewConstraints()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
     
        backgroundColor = .clear
        
    }
    
    func addViews() {
        [dimmedView, containerView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        dimmedViewConstraints()
        containerViewConstraints()
        topLabelConstraints()
        xButtonConstraints()
        titleLabelConstraints()
        titleTextViewConstraints()
        dateViewConstraints()
    }
    
    private func dimmedViewConstraints() {
        dimmedView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    private func containerViewConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 616)
        ])
    }
    
    private func xButtonConstraints() {
        xButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            xButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            xButton.widthAnchor.constraint(equalToConstant: 48),
            xButton.heightAnchor.constraint(equalToConstant: 48)

        ])
    }
    
    private func topLabelConstraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            topLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32)
        ])
    }
    
    private func titleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 31)
        ])
    }
    
    private func titleTextViewConstraints() {
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        textPlaceHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        textCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 125),
            titleTextView.widthAnchor.constraint(equalToConstant: 343),
            titleTextView.heightAnchor.constraint(equalToConstant: 50),
            
            textPlaceHolderLabel.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor, constant: 13),
            textPlaceHolderLabel.topAnchor.constraint(equalTo: titleTextView.topAnchor, constant: 16),

            textCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            textCountLabel.bottomAnchor.constraint(equalTo: titleTextView.topAnchor, constant: -20)
        ])
    }
    
    private func dateViewConstraints() {
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            dateTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateTextField.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 61),
            dateTextField.widthAnchor.constraint(equalToConstant: 343),
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            dateTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateTitleLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 27),

        ])
    }
    
    
    func dateInputViewConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            saveButton.leadingAnchor.constraint(equalTo: dateInputView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: dateInputView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 52)

        ])
    }
}

//텍스트 입력 좌측 패딩 13
extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
