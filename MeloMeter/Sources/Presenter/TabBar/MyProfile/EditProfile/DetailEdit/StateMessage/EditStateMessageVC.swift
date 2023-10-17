//
//  EditStatusMessageVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
import RxSwift
import RxGesture

class EditStateMessageVC: UIViewController {
    
    private let viewModel: DetailEditVM?
    private let disposeBag = DisposeBag()

    init(viewModel: DetailEditVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusTextField.delegate = self
        configure()
        setAutoLayout()
        setBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar()
        self.statusTextField.text = self.viewModel?.stateMessage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.statusTextField.becomeFirstResponder()
    }
    
    // MARK: Bindings
    func setBindings() {
        view.rx.tapGesture().when(.ended)
            .subscribe(onNext: {[weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let input = DetailEditVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            changedName: nil,
            changedStateMessage: self.completeButton.rx.tap
                .map{ _ in
                    return self.statusTextField.text ?? ""
                },
            changedBirth: nil
        )
        
        guard let output = self.viewModel?.stateMessageTransform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.inputError
            .subscribe(onNext: {[weak self] isError in
                if isError {
                    self?.showInputErrorAlert()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: Event
    func showInputErrorAlert() {
        AlertManager(viewController: self)
            .showNomalAlert(title: "편집 실패", message: "상태메세지를 다시 입력해주세요!")
            .subscribe(onSuccess: {
                self.statusTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
 
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [exLabel, statusTextField, statusTextCountLabel].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "상태메세지"
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.rightBarButtonItem?.tintColor = .black
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
    
    private lazy var completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "등록",
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 기분을 표현해보세요."
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var statusTextField: UITextField = {
        let tv = UITextField()
        // 플레이스홀더에 표시할 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray3,
            .font: FontManager.shared.medium(ofSize: 16)
        ]
        tv.attributedPlaceholder = NSAttributedString(string: "원하는 말을 적어보세요!", attributes: attributes)
        tv.backgroundColor = .gray5
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.keyboardType = .default
        tv.tintColor = .gray1
        tv.addLeftPadding()
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = false
        return tv
    }()
    
    
    var statusTextCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = FontManager.shared.medium(ofSize: 13)
        label.textColor = .gray2
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        statusViewConstraints()
    }
    private func statusViewConstraints() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        statusTextField.translatesAutoresizingMaskIntoConstraints = false
        statusTextCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            statusTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            statusTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            statusTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            statusTextField.heightAnchor.constraint(equalToConstant: 50),
          
            statusTextCountLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            statusTextCountLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }
}

// MARK: TextFieldDelegate
extension EditStateMessageVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.isEnabled = true //등록버튼 활성화
        
        guard let currentText = textField.text else { return true }
        
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            return false
        }
        self.statusTextCountLabel.text = "\(newLength)/10"
        
        return true
    }
}
