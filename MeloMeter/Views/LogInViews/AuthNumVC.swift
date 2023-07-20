//
//  AuthNumVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/24.
//

import UIKit
import AnyFormatKit //번호 입력 형식 라이브러리
import Firebase
import RxCocoa
import RxSwift

// MARK: - 인증번호 입력
final class AuthNumVC: UIViewController {
 
    let viewModel: LogInVM
    let disposeBag = DisposeBag()
    let progressDialog: ProgressDialogView = ProgressDialogView()
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
        authNumTF.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopTimer() // 타이머 해제
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
                self.viewModel.verificationCode.onNext(self.authNumTF.text)
            })
            .disposed(by: disposeBag)
        
        viewModel.logInRequest.subscribe(onNext: { [weak self] result in
            guard let self = self else{ return }
            if result == false {
//                AlertManager.shared.showNomalAlert(title: "인증 실패", message: "다시 입력해주세요")
//                    .subscribe(onSuccess: {
//                        self.authNumTF.text = ""
//                        self.dismiss(animated: true)
//                    }).disposed(by: disposeBag)
            }
        }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else{ return }
                self.authNumTF.text = ""
                self.cancelBtn.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.verificationCodeTimer()
        viewModel.timerString
            .bind(to: self.timeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.timerDisposed
            .subscribe(onNext: { result in
                if result {
                    self.timeLabel.text = "00:00"
//                    AlertManager.shared.showNomalAlert(title: "시간 초과", message: "인증을 다시 시도해주세요")
//                        .subscribe(onSuccess: {
//                        }).disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Event
    func showProgressDialog() {
        self.progressDialog.show()
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
    }
    
    // MARK: - configure
    private func configure() {
        view.backgroundColor = .white
        authNumTF.delegate = self
        [progressImage, titleLabel, authNumTF, lineView, exLabel, cancelBtn, timeLabel, retransBtn].forEach { view.addSubview($0) }
    }
    
    // MARK: - UI
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "인증번호를\n입력하세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    lazy var authNumTF: UITextField = {
        let tv = UITextField()
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "인증 번호 입력", attributes: attributes)
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
    private let nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
        button.isEnabled = true
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "전송된 인증번호는 10분 안에 인증이 만료됩니다"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
    }()
    
    let cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.backgroundColor = .white
        //button.isHidden = true
        return button
    }()
    
    //시간 표시
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "04:59"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    //재전송 버튼
    let retransBtn: UIButton = {
        let button = UIButton()
        button.setTitle("재전송 받기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        return button
    }()
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        progressConstraints()
        titleLabelConstraints()
        authNumTFConstraints()
        exLabelConstraints()
        nextInputViewConstraints()
    }
    
    private func progressConstraints() {
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 167),
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
    
    private func authNumTFConstraints() {
        authNumTF.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            authNumTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            authNumTF.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView.topAnchor.constraint(equalTo: authNumTF.bottomAnchor, constant: 12),
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            
            cancelBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -3),
            cancelBtn.bottomAnchor.constraint(equalTo: lineView.topAnchor),
            cancelBtn.widthAnchor.constraint(equalToConstant: 44),
            cancelBtn.heightAnchor.constraint(equalToConstant: 44),

        ])
    }
    
    private func exLabelConstraints() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        retransBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
            
            timeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 11),

            retransBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -256),
            retransBtn.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 10),
            retransBtn.widthAnchor.constraint(equalToConstant: 64),
            retransBtn.heightAnchor.constraint(equalToConstant: 20)
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
extension AuthNumVC: UITextFieldDelegate {
    //길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        cancelBtn.isHidden = false
        guard let currentText = textField.text else { return true }
        
        let newLength = currentText.count + string.count - range.length
        if newLength > 6 {
            return false
        }
        return true
    }
}
