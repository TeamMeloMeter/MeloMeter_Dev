//
//  PhoneCertifiedVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/22.
//

import UIKit
import AnyFormatKit //번호 입력 형식 라이브러리
import Firebase
import RxSwift
import RxCocoa

// MARK: - 전화번호입력
final class PhoneCertifiedVC: UIViewController {
    
    let viewModel: LogInVM
    let disposeBag = DisposeBag()
    let progressDialog:ProgressDialogView = ProgressDialogView()
    let tapGesture = UITapGestureRecognizer()
    
    init(viewModel: LogInVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        phoneNumTF.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideProgressDialog()
    }
    
    // MARK: - Binding
    func setBindings() {
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        nextBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else{ return }
                self.view.endEditing(true)
                self.view.addSubview(progressDialog)
                showProgressDialog()
                self.viewModel.phoneNumberInput.onNext(self.phoneNumTF.text)
            })
            .disposed(by: disposeBag)
        
        viewModel.sendNumRequest.subscribe(onNext: { [weak self] result in
            guard let self = self else{ return }
            if result == false {
                AlertManager(viewController: self)
                    .showNomalAlert(title: "다시 입력해주세요", message: "올바르지 않은 전화번호")
                    .subscribe(onSuccess: {
                        self.phoneNumTF.text = ""
                        self.cancelBtn.isHidden = true
                        self.nextBtnEnabledF()
                        self.lineColorChangedF()
                    }).disposed(by: disposeBag)
            }
        }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else{ return }
                cancelBtnTapped()
            }).disposed(by: disposeBag)
    }
    
    func showProgressDialog() {
        self.progressDialog.show()
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
    }
    
    // MARK: - Event
    // x버튼 입력한 번호 지우기
    func cancelBtnTapped() {
        phoneNumTF.text = ""
        cancelBtn.isHidden = true
        nextBtnEnabledF()
        lineColorChangedF()
    }
    //다음 버튼 활성화
    private func nextBtnEnabledT() {
        nextBtn.isEnabled = true
        nextBtn.alpha = 1.0
        nextBtn.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    //다음 버튼 비활성화
    private func nextBtnEnabledF() {
        nextBtn.isEnabled = false
        nextBtn.alpha = 0.5
        nextBtn.layer.applyShadow(color: #colorLiteral(red: 0.9341433644, green: 0.9341433644, blue: 0.9341433644, alpha: 1), alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    
    //그라데이션 뷰 적용
    private func lineColorChangedT() {
        lineView.setGradientBackground(colors: [.primary1, .white])
    }
    
    //그라데이션 뷰 삭제
    private func lineColorChangedF() {
        //layer에서 그라데이션뷰를 찾아 제거
        lineView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        lineView.backgroundColor = .gray2
    }

    // MARK: - configure
    private func configure() {
        view.backgroundColor = .white
        phoneNumTF.delegate = self
        [progressImage, titleLabel, phoneNumTF, lineView, exLabel, cancelBtn].forEach { view.addSubview($0) }
    }
    
    
    // MARK: - UI
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "멜로미터 시작을 위하여\n휴대폰 번호를 입력해 주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    lazy var phoneNumTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.placeholder = "휴대폰 번호 입력"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "휴대폰 번호 입력", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    lazy var nextInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(nextBtn)
        
        return view
    }()
    
    // 다음버튼
    let nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        button.layer.applyShadow(color: #colorLiteral(red: 0.9341433644, green: 0.9341433644, blue: 0.9341433644, alpha: 1), alpha: 1.0, x: 4, y: 0, blur: 10)
        
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "‘다음’을 누르시면, 입력한 번호로 인증번호가 전송됩니다\n이미 계정이 있으신 경우, 번호 입력->인증을 재진행 해주세요"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let range = NSRange(location: 46, length: 15)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.semiBold(ofSize: 12),
            .foregroundColor: UIColor.gray1
        ]
        attributedString.addAttributes(attributes, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    let cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.backgroundColor = .white
        button.isHidden = true
        return button
    }()
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        progressConstraints()
        titleLabelConstraints()
        phoneNumConstraints()
        exLabelConstraints()
        nextInputViewConstraints()
    }
    
    private func progressConstraints() {
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            progressImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 68),
            progressImage.widthAnchor.constraint(equalToConstant: 42),
            progressImage.heightAnchor.constraint(equalToConstant: 5)
            
        ])
    }
    
    private func titleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: progressImage.bottomAnchor, constant: 51),
        ])
    }
    
    private func phoneNumConstraints() {
        phoneNumTF.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            phoneNumTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            phoneNumTF.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView.topAnchor.constraint(equalTo: phoneNumTF.bottomAnchor, constant: 12),
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            
            cancelBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -3),
            cancelBtn.bottomAnchor.constraint(equalTo: lineView.topAnchor),
            cancelBtn.widthAnchor.constraint(equalToConstant: 44),
            cancelBtn.heightAnchor.constraint(equalToConstant: 44),

        ])
    }
    
    private func exLabelConstraints() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
        ])
    }
    private func nextInputViewConstraints() {
        nextBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            nextBtn.leadingAnchor.constraint(equalTo: nextInputView.leadingAnchor),
            nextBtn.trailingAnchor.constraint(equalTo: nextInputView.trailingAnchor),
            nextBtn.heightAnchor.constraint(equalToConstant: 52)

        ])
    }
}

// MARK: - 텍스트필드 Delegate
extension PhoneCertifiedVC: UITextFieldDelegate {
    
    //번호 입력 포멧, 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        cancelBtn.isHidden = false
        guard let text = textField.text else {
            return false
        }
        let characterSet = CharacterSet(charactersIn: string)
        if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
            return false
        }
        let formatter = DefaultTextInputFormatter(textPattern: "###-####-####")
        let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
        textField.text = result.formattedText
        let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
        textField.selectedTextRange = textField.textRange(from: position, to: position) // 커서 위치 변경해주기
        if result.formattedText.count == 13 { //번호 전부 입력 시
            nextBtnEnabledT() //다음 버튼 활성화
            lineColorChangedT()
        }else {
            nextBtnEnabledF() //아니면 비활성화
            lineColorChangedF()
        }
        return false
    }
    
}
