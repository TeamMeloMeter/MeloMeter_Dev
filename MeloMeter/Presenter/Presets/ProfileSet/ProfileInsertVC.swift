//
//  ProfileInsertVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/03.
//

import UIKit
import RxCocoa
import RxSwift
import AnyFormatKit

final class ProfileInsertVC: UIViewController {
    
    private let viewModel: ProfileInsertVM
    let disposeBag = DisposeBag()
    let tapGesture = UITapGestureRecognizer()
    let progressDialog: ProgressDialogView = ProgressDialogView()
    
    //텍스트필드 유효입력 확인
    var checkTextField : [Bool] = Array(repeating: false, count: 3)
    
    var activeTextField: UITextField? = nil
    
    //키보드 알림 등록 객체 생성
    let keyboardDetector = KeyboardStatusDetector()
    
    init(viewModel: ProfileInsertVM) {
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
    }
    
    // MARK: - Binding
    func setBindings() {
        view.addGestureRecognizer(tapGesture)
        
        //다음버튼 터치이벤트
        nextBtn.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else{ return }
                self.view.endEditing(true)
                self.view.addSubview(progressDialog)
                showProgressDialog()
                self.viewModel.checkFormat(info: [self.nameTF.text, self.birthTF.text, self.firstDayTF.text])
                    .subscribe(onSuccess: { check in
                        if check {
                            self.viewModel.userInput.onNext([self.nameTF.text, self.birthTF.text, self.firstDayTF.text])
                        }else {
                            self.dateFormatError()
                        }
                    }).disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        //유저정보 데이터베이스 삽입 확인
        viewModel.sendProfileInsertRequest
            .bind(onNext: {[weak self] result in
                guard let self = self else{ return }
                if result == false {
                    insertError()
                }
            }).disposed(by: disposeBag)
        
        //화면터치 이벤트
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        //키보드 show/hide 감지
        keyboardDetector.keyboardStatusSubject
            .subscribe(onNext: { [weak self] isKeyboardShown in
                self?.handleKeyboardStatusChange(isKeyboardShown)
            }).disposed(by: disposeBag)
    }
    // MARK: - Event
    func handleKeyboardStatusChange(_ isKeyboardShown: [Any]) {
        if isKeyboardShown[0] as? Bool ?? false {
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.insertSubViwes.transform = CGAffineTransform(translationX: 0, y: (isKeyboardShown[1] as? CGFloat ?? 0) * -1 + 212)
                })
            self.titleLabel.isHidden = true
        } else {
            self.insertSubViwes.transform = .identity
            self.titleLabel.isHidden = false
        }
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
    private func lineColorChangedT( _ lineView: UIView ) {
        lineView.setGradientBackground(colors: [.primary1, .white])
    }
    
    //그라데이션 뷰 삭제
    private func lineColorChangedF( _ lineView: UIView ) {
        //layer에서 그라데이션뷰를 찾아 제거
        lineView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        lineView.backgroundColor = .gray2
    }
    
    //오류 알럿
    func dateFormatError() {
        AlertManager(viewController: self)
            .setTitle("잘못된 날짜형식")
            .setMessage("날짜형식이 일치하지 않습니다\n 올바른 형식의 날짜를\n 입력해주세요")
            .addActionConfirm("확인")
            .showCustomAlert()
        hideProgressDialog()
    }
    func insertError() {
        AlertManager(viewController: self)
            .setTitle("통신실패")
            .setMessage("서버와 통신에 실패했습니다\n 잠시후 다시\n 시도해주세요")
            .addActionConfirm("확인")
            .showCustomAlert()
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
        nameTF.delegate = self
        birthTF.delegate = self
        firstDayTF.delegate = self
        
        nextBtnEnabledF()
        
        [insertSubViwes, progressImage].forEach { view.addSubview($0) }
    }
    
    // MARK: - UI
    lazy var insertSubViwes: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(nameLabel)
        view.addSubview(nameTF)
        view.addSubview(birthLabel)
        view.addSubview(birthTF)
        view.addSubview(firstDayLabel)
        view.addSubview(firstDayTF)
        view.addSubview(exLabel)
        view.addSubview(lineView1)
        view.addSubview(lineView2)
        view.addSubview(lineView3)
        
        return view
    }()
    
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress4")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "연결 완료!\n멜로미터 시작 전\n프로필을 입력해주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var nameTF: UITextField = {
        let tv = UITextField()
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "이름 or 원하는 닉네임을 입력해주세요", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .default
        tv.tintColor = .gray1
        
        // 텍스트필드 구별을 위한 태그 달기
        tv.tag = 0
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    private let birthLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var birthTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "만 14세 이상 입력이 가능합니다", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        
        // 텍스트필드 구별을 위한 태그 달기
        tv.tag = 1
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()
    
    private let firstDayLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 만난 날"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var firstDayTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "처음 만난 날을 입력해주세요", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        
        // 텍스트필드 구별을 위한 태그 달기
        tv.tag = 2
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 정보는 서비스 최적화를 위해서만 사용됩니다"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
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
        button.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
        button.isEnabled = true
        return button
    }()
    
    let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    let lineView3: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        progressConstraint()
        titleLabelConstraint()
        textFieldsConstraint()
        nextInputViewConstraints()
        insertSubViewsConstraint()
    }
    
    private func insertSubViewsConstraint() {
        insertSubViwes.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //좌
            insertSubViwes.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            //우
            insertSubViwes.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            //상
            insertSubViwes.topAnchor.constraint(equalTo: self.view.topAnchor),
            //하
            insertSubViwes.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -212)
        ])
    }
    
    private func progressConstraint() {
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            progressImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 68),
            progressImage.widthAnchor.constraint(equalToConstant: 42),
            progressImage.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    private func titleLabelConstraint() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: progressImage.bottomAnchor, constant: 51),
        ])
    }
    
    private func textFieldsConstraint() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTF.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false

        birthLabel.translatesAutoresizingMaskIntoConstraints = false
        birthTF.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        
        firstDayLabel.translatesAutoresizingMaskIntoConstraints = false
        firstDayTF.translatesAutoresizingMaskIntoConstraints = false
        lineView3.translatesAutoresizingMaskIntoConstraints = false
        
        exLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //이름
            nameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),

            nameTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            nameTF.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            
            lineView1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView1.topAnchor.constraint(equalTo: nameTF.bottomAnchor, constant: 9),
            lineView1.heightAnchor.constraint(equalToConstant: 1),
            
            //생일
            birthLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            birthLabel.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 34),

            birthTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            birthTF.topAnchor.constraint(equalTo: birthLabel.bottomAnchor, constant: 9),
            
            lineView2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView2.topAnchor.constraint(equalTo: birthTF.bottomAnchor, constant: 9),
            lineView2.heightAnchor.constraint(equalToConstant: 1),
            
            //처음 만난 날
            firstDayLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            firstDayLabel.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 34),

            firstDayTF.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            firstDayTF.topAnchor.constraint(equalTo: firstDayLabel.bottomAnchor, constant: 9),
            
            lineView3.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lineView3.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lineView3.topAnchor.constraint(equalTo: firstDayTF.bottomAnchor, constant: 9),
            lineView3.heightAnchor.constraint(equalToConstant: 1),
            
            //설명
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView3.bottomAnchor, constant: 22),


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
extension ProfileInsertVC: UITextFieldDelegate {

    //번호 입력 포멧, 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        cancelBtn.isHidden = false
        guard let text = textField.text else {
            return false
        }
        let characterSet = CharacterSet(charactersIn: string)
        
        let nowLineView : UIView
        if textField.tag == 0 {
            nowLineView = self.lineView1
            
            guard let currentText = textField.text else {
                lineColorChangedF(nowLineView)
                return true
            }
            let newLength = currentText.count + string.count - range.length
            
            
            if newLength == 0{
                lineColorChangedF(nowLineView)
                checkTextField[textField.tag] = false
                return true
            }else if newLength <= 10 {
                lineColorChangedT(nowLineView)
                checkTextField[textField.tag] = true
                return true
            }else{
                checkTextField[textField.tag] = true
            }
            
        } else if textField.tag == 1 {
            //숫자만 입력받기
            if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
                return false
            }
            
            let formatter = DefaultTextInputFormatter(textPattern: "####-##-##")
            let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
            textField.text = result.formattedText
            
            nowLineView = self.lineView2
            if result.formattedText.count == 10 { //생년월일 전부 입력 시
                lineColorChangedT(nowLineView)
                checkTextField[textField.tag] = true
            }else {
                lineColorChangedF(nowLineView)
                checkTextField[textField.tag] = false
            }
            
            //커서 포지션 next
            let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
            textField.selectedTextRange = textField.textRange(from: position, to: position) // 커서 위치 변경해주기
            
        } else if textField.tag == 2 {
            //숫자만 입력받기
            if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
                return false
            }
            
            let formatter = DefaultTextInputFormatter(textPattern: "####-##-##")
            let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
            textField.text = result.formattedText
            
            nowLineView = self.lineView3
            if result.formattedText.count == 10 { //처음만난날 전부 입력 시
                lineColorChangedT(nowLineView)
                checkTextField[textField.tag] = true
            }else {
                lineColorChangedF(nowLineView)
                checkTextField[textField.tag] = false
            }
            
            //커서 포지션 next
            let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
            textField.selectedTextRange = textField.textRange(from: position, to: position) // 커서 위치 변경해주기
        }
        
        if checkTextField == [true, true, true]{
            nextBtnEnabledT() //다음 버튼 활성화
        }else {
            nextBtnEnabledF() //아니면 비활성화
        }
        
        return false
    }
    
}
