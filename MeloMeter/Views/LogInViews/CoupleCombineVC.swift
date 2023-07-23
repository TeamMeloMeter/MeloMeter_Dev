//
//  CoupleConnectVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/27.
//

import UIKit
import RxCocoa
import RxSwift
import AnyFormatKit //입력 형식 라이브러리
import Firebase
// MARK: - 커플 등록
final class CoupleCombineVC: UIViewController {
   
    private let viewModel: LogInVM
    let disposeBag = DisposeBag()
    let progressDialog: ProgressDialogView = ProgressDialogView()
    
    init(viewModel: LogInVM, inviteCode: String, inviteCode2: String? = nil) {
        self.viewModel = viewModel
        self.myCodeLabel.text = inviteCode
        super.init(nibName: nil, bundle: nil)
        if let code2 = inviteCode2 {
            self.codeTF.text = code2
        }
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
        codeTF.becomeFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopTimer() // 타이머 해제
        hideProgressDialog()
    }
    
    // MARK: - Binding
    func setBindings() {
        viewModel.myCode
            .bind(to: self.myCodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        nextBtn.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else{ return }
                self.view.endEditing(true)
                self.view.addSubview(progressDialog)
                showProgressDialog()
                self.viewModel.inviteCodeInput.onNext(self.codeTF.text)
            })
            .disposed(by: disposeBag)
        
        viewModel.combineRequest
            .bind(onNext: {[weak self] result in
                guard let self = self else{ return }
                if result == false {
                    combineError()
                }
            }).disposed(by: disposeBag)
        
        viewModel.inviteCodeTimer()
        viewModel.timerString
            // .bind(to:  <= 바인딩 된 객체값을 우측값에 대입
            .bind(to: self.user1Label.rx.text)
            .disposed(by: disposeBag)
        viewModel.timerDisposed
            .bind(onNext: { result in
                if result {
                    self.timeOut()
                }
            }).disposed(by: disposeBag)
        
        shareBtn.rx.tap
            .subscribe(onNext: {
                guard let inviteCode = self.myCodeLabel.text else{ return }
                self.viewModel.shareKakao(inviteCode: inviteCode)
            }).disposed(by: disposeBag)
    }
    
    //MARK: Event
    func combineError() {
        AlertManager(viewController: self)
            .setTitle("잘못된 코드")
            .setMessage("초대코드가 일치하지 않습니다\n 올바른 상대방의 초대코드를\n 입력해주세요")
            .addActionConfirm("확인")
            .showCustomAlert()
        hideProgressDialog()
    }
    func timeOut() {
        AlertManager(viewController: self)
            .setTitle("00:00:00")
            .setMessage("24시간 초대 코드가 만료되었습니다\n재발급 된 상대방의 코드를\n다시 입력해주세요")
            .addActionConfirm("확인", action: {self.viewModel.inviteCodeTimer()})
            .showCustomAlert()
        self.codeTF.text = ""
        nextBtnEnabledF()
        hideProgressDialog()
    }
    
    func showProgressDialog() {
        self.progressDialog.show()
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
    }
    
    
    // MARK: - configure
    func configure() {
        view.backgroundColor = .white
        codeTF.delegate = self
        [progressImage, titleLabel, user1Label, myCodeLabel, shareBtn, lineView1,
        user2Label, codeTF, lineView2,
         questLabel, contactBtn].forEach { view.addSubview($0) }
        
    }
    
    // MARK: - UI
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress3")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "커플 연결을 위해\n서로의 초대코드를 입력해주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    let user1Label: UILabel = {
        let label = UILabel()
        label.text = "내 초대코드(23:59:59)"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    //내 코드 표시
    let myCodeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    let lineView1: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 343, height: 1.5))
    
    let shareBtn: UIButton = {
        let button = UIButton()
        button.setTitle("공유", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9971519113, green: 0.4873556495, blue: 0.9974393249, alpha: 0.22)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        return button
    }()
    
    let user2Label: UILabel = {
        let label = UILabel()
        label.text = "상대방 초대코드"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var codeTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "상대방 초대코드 입력", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    private let questLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "연결에 문제가 있나요?"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    //문의버튼
    let contactBtn: UIButton = {
        let button = UIButton()
        button.setTitle("문의하기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        return button
    }()
    
    // 다음버튼
    lazy var nextInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(nextBtn)
        
        return view
    }()
    let nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("연결하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
        button.isEnabled = true
        return button
    }()
    
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        progressConstraints()
        titleLabelConstraints()
        myCodeConstraints()
        user2Constraints()
        contactConstraints()
        nextInputViewConstraints()
        lineView1.setGradientBackground(colors: [.primary1, .white])
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
    
    private func myCodeConstraints() {
        user1Label.translatesAutoresizingMaskIntoConstraints = false
        myCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            user1Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            user1Label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            myCodeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            myCodeLabel.topAnchor.constraint(equalTo: user1Label.bottomAnchor, constant: 15),
            
            shareBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            shareBtn.bottomAnchor.constraint(equalTo: myCodeLabel.bottomAnchor),
            shareBtn.widthAnchor.constraint(equalToConstant: 54),
            shareBtn.heightAnchor.constraint(equalToConstant: 32),
            
            lineView1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView1.topAnchor.constraint(equalTo: shareBtn.bottomAnchor, constant: 12),
        ])
    }
    
    private func user2Constraints() {
        user2Label.translatesAutoresizingMaskIntoConstraints = false
        codeTF.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            user2Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            user2Label.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 40),
            
            codeTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            codeTF.topAnchor.constraint(equalTo: user2Label.bottomAnchor, constant: 15),
            
            lineView2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView2.topAnchor.constraint(equalTo: codeTF.bottomAnchor, constant: 10),
            lineView2.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    private func contactConstraints() {
        questLabel.translatesAutoresizingMaskIntoConstraints = false
        contactBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            questLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            questLabel.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 22),
            
            contactBtn.leadingAnchor.constraint(equalTo: questLabel.trailingAnchor, constant: 9),
            contactBtn.topAnchor.constraint(equalTo: questLabel.topAnchor),
            contactBtn.widthAnchor.constraint(equalToConstant: 49),
            contactBtn.heightAnchor.constraint(equalToConstant: 17)
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

// MARK: - 텍스트필드 델리게이트
extension CoupleCombineVC: UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let characterSet = CharacterSet(charactersIn: string)
        if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
            return false
        }
        let formatter = DefaultTextInputFormatter(textPattern: "#### ####")
        let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
        textField.text = result.formattedText
        let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
        textField.selectedTextRange = textField.textRange(from: position, to: position) // 커서 위치 변경해주기
        if result.formattedText.count == 9 { //번호 전부 입력 시
            nextBtnEnabledT() //다음 버튼 활성화
            lineColorChangedT()
        }else {
            nextBtnEnabledF() //아니면 비활성화
            lineColorChangedF()
        }
        return false
    }
    //연결 버튼 활성화
    private func nextBtnEnabledT() {
        nextBtn.isEnabled = true
        nextBtn.alpha = 1.0
        nextBtn.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    
    //연결 버튼 비활성화
    private func nextBtnEnabledF() {
        nextBtn.isEnabled = false
        nextBtn.alpha = 0.5
        nextBtn.layer.applyShadow(color: #colorLiteral(red: 0.9341433644, green: 0.9341433644, blue: 0.9341433644, alpha: 1), alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    
    //그라데이션 뷰 적용
    private func lineColorChangedT() {
        lineView2.setGradientBackground(colors: [.primary1, .white])
    }
    
    //그라데이션 뷰 삭제
    private func lineColorChangedF() {
        //layer에서 그라데이션뷰를 찾아 제거
        lineView2.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        lineView2.backgroundColor = .gray2
    }
}
