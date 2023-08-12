//
//  EditBirthViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
import RxSwift
import RxGesture

class EditBirthVC: UIViewController {
    
    private let viewModel: DetailEditVM?
    private let disposeBag = DisposeBag()

    init(viewModel: DetailEditVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar()
        self.birthTextField.text = self.viewModel?.birth
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.birthTextField.becomeFirstResponder()
    }
    
    // MARK: Bindings
    func setBindings() {
        view.rx.tapGesture().when(.ended)
            .subscribe(onNext: {[weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        self.datePicker.rx.date
            .map({ date in
                return date.toString(type: .yearToDay)
            })
            .bind(to: self.birthTextField.rx.text)
            .disposed(by: disposeBag)
        
        let input = DetailEditVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            changedName: nil,
            changedStateMessage: nil,
            changedBirth: self.completeButton.rx.tap
                .map{ _ in
                    return self.birthTextField.text ?? ""
                }
        )
        
        guard let output = self.viewModel?.birthTransform(input: input, disposeBag: self.disposeBag) else{ return }
        
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
            .showNomalAlert(title: "편집 실패", message: "생일을 다시 설정해주세요!")
            .subscribe(onSuccess: {
                self.birthTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }

    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [exLabel, birthTextField].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "생일"
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
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var birthTextField: UITextField = {
        let tv = UITextField()
        
        tv.backgroundColor = .gray5
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.keyboardType = .default
        tv.tintColor = .gray1
        tv.inputView = datePicker
        tv.becomeFirstResponder()
        tv.addLeftPadding()
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = false
        return tv
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.backgroundColor = UIColor.white
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        return datePicker
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 오토레이아웃
    private func setAutoLayout() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        birthTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            birthTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            birthTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            birthTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            birthTextField.heightAnchor.constraint(equalToConstant: 49),

        ])
    }

}

