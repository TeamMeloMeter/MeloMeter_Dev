//
//  EditNameViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
import RxSwift
import RxCocoa

class EditNameVC: UIViewController {
    
    private let viewModel: DetailEditVM?
    private let disposeBag = DisposeBag()

    init(viewModel: DetailEditVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        configure()
        setAutoLayout()
        setBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar()
        self.nameTextField.text = self.viewModel?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nameTextField.becomeFirstResponder()
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
            changedName: self.completeButton.rx.tap
                .map{ _ in
                    return self.nameTextField.text ?? ""
                },
            changedStateMessage: nil,
            changedBirth: nil
        )
        
        guard let output = self.viewModel?.nameTransform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.inputError
            .subscribe(onNext: {[weak self] isError in
                if isError {
                    self?.showInputErrorAlert()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [exLabel, nameTextField, nameTextCountLabel].forEach { view.addSubview($0) }
    }
    
    // MARK: Event
    func showInputErrorAlert() {
        AlertManager(viewController: self)
            .showNomalAlert(title: "편집 실패", message: "이름을 다시 입력해주세요!")
            .subscribe(onSuccess: {
                self.nameTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "이름"
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
    
    // MARK: UI
    let exLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방에게 표시되는 이름이에요."
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let tv = UITextField()
        
        tv.text = ""
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
    
    var nameTextCountLabel: UILabel = {
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
        nameTFViewConstraints()
    }
    
    
    private func nameTFViewConstraints() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            nameTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            nameTextCountLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextCountLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),

        ])
    }
}

// MARK: TextFieldDelegate
extension EditNameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.isEnabled = true //등록버튼 활성화
        
        guard let currentText = textField.text else { return true }
        
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            return false
        }
        self.nameTextCountLabel.text = "\(newLength)/10"
        
        return true
    }
}
