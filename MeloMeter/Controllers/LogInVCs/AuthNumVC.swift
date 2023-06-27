//
//  AuthNumVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/24.
//

import UIKit
import AnyFormatKit //번호 입력 형식 라이브러리
import FirebaseAuth
import FirebaseAppCheck
//인증번호
class AuthNumVC: UIViewController, UITextFieldDelegate {
    
    let authNumView = AuthNumView()
    let authModel = AuthModel()
    override func loadView() {
        view = authNumView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        authNumView.authNumTF.delegate = self
        authNumView.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        authNumView.nextBtn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        authNumView.authNumTF.becomeFirstResponder()
    }
    
    // x버튼 입력한 번호 지우기
    @objc func cancelBtnTapped() {
        authNumView.authNumTF.text = ""
        authNumView.cancelBtn.isHidden = true
    }
    
    //길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        authNumView.cancelBtn.isHidden = false
        guard let currentText = textField.text else { return true }
        
        let newLength = currentText.count + string.count - range.length
        if newLength > 6 {
            return false
        }        
        return true
    }

    //다음버튼 터치이벤트
    @objc func nextBtnTapped() {
        guard let verificationCode = authNumView.authNumTF.text, let verificationID = UserDefaults.standard.string(forKey: "verificationID") else{ return }
        print("UserDefaults: \(verificationID)")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )

        logIn(credential: credential)
    }
    
    //로그인
    func logIn(credential: PhoneAuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                print("LogIn Failed...")
            }else {
                print("LogIn Success!!")
                print("\\(authResult!)")
                let ccVC = CoupleConnectVC()
                ccVC.modalPresentationStyle = .fullScreen
                self.present(ccVC, animated: true, completion: nil)
            }
            
        }
    }
}
