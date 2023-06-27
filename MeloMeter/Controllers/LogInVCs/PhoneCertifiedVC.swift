//
//  PhoneCertifiedVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/22.
//

import UIKit
import AnyFormatKit //번호 입력 형식 라이브러리
import Firebase
import FirebaseAppCheck
//전화번호 인증
class PhoneCertifiedVC: UIViewController, UITextFieldDelegate {
    
    let phoneCertifiedView = PhoneCertifiedView()
    
    
    override func loadView() {
        view = phoneCertifiedView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneCertifiedView.phoneNumTF.delegate = self
        phoneCertifiedView.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        phoneCertifiedView.nextBtn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        phoneCertifiedView.phoneNumTF.becomeFirstResponder()
    }
    // x버튼 입력한 번호 지우기
    @objc func cancelBtnTapped() {
        phoneCertifiedView.phoneNumTF.text = ""
        phoneCertifiedView.cancelBtn.isHidden = true
        nextBtnEnabledF()
        lineColorChangedF()
    }
    
    //번호 입력 포멧, 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        phoneCertifiedView.cancelBtn.isHidden = false
        
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
    
    //다음 버튼 활성화
    private func nextBtnEnabledT() {
        phoneCertifiedView.nextBtn.isEnabled = true
        phoneCertifiedView.nextBtn.alpha = 1.0
        phoneCertifiedView.nextBtn.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    //다음 버튼 비활성화
    private func nextBtnEnabledF() {
        phoneCertifiedView.nextBtn.isEnabled = false
        phoneCertifiedView.nextBtn.alpha = 0.5
        phoneCertifiedView.nextBtn.layer.applyShadow(color: #colorLiteral(red: 0.9341433644, green: 0.9341433644, blue: 0.9341433644, alpha: 1), alpha: 0.4, x: 4, y: 0, blur: 10)
    }
    
    //그라데이션 뷰 적용
    private func lineColorChangedT() {
        phoneCertifiedView.lineView.setGradientBackground(colors: [.primary1, .white])
    }
    //선 색상 블랙
    private func lineColorChangedF() {
        //layer에서 그라데이션뷰를 찾아 제거
        phoneCertifiedView.lineView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        phoneCertifiedView.lineView.backgroundColor = .gray2
    }

    //다음버튼 터치이벤트: 전화번호 인증 요청 전송
    @objc func nextBtnTapped() {
        if let number = phoneCertifiedView.phoneNumTF.text?.components(separatedBy: "-").joined() {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = true // 테스트모드
            //Analytics.setAnalyticsCollectionEnabled(true)
            let authModel = AuthModel()
            authModel.phoneNum = "+82 \(number)"
            authModel.sendNumber()
        }
        
        let authNumVC = AuthNumVC()
        authNumVC.modalPresentationStyle = .fullScreen
        self.present(authNumVC, animated: true, completion: nil)
    }
}
