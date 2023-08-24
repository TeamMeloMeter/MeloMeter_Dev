//
//  WithdrawalVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit
import RxSwift

class WithdrawalVC: UIViewController {
    
    private let viewModel: AccountsVM?
    private let disposeBag = DisposeBag()

    init(viewModel: AccountsVM) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Bindings
    func setBindings() {
        let input = AccountsVM.Input(
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            excuteBtnEvent: self.withdrawalBtn.rx.tap
                .map({ .withdrawal })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.withdrawalFailed
            .subscribe(onNext: {[weak self] result in
                if result {
                    self?.withdrawalErrorAlert()
                }
            })
            .disposed(by: disposeBag)
    }
   
    //MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [titleLabel, exLabel, lineView, withdrawalBtn].forEach { view.addSubview($0) }
    }
    
    // MARK: Event
    func withdrawalErrorAlert() {
        AlertManager(viewController: self)
            .setTitle("탈퇴 오류")
            .setMessage(
            """
            서버와 통신에 실패했습니다.
            잠시후 다시 시도해주세요.
            """
            )
            .addActionConfirm("확인")
            .showCustomAlert()
    }
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "연결 끊기"
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
    
    
    //MARK: UI
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "멜로미터 탈퇴 전 확인해주세요"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()
  
    private let exLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        let labelText = """
더 이상 멜로미터 사용을 원하지 않을 경우, 먼저 연결을 끊어야 합니다. 멜로미터 앱 내에서
<마이페이지 - 프로필 편집 - 상대방과 연결 끊기> 를
통해 상대방과 연결을 끊을 수 있습니다.

연결이 끊어지면 기존 자료에 대한 접근이 차단됩니다.
연결을 끊은 후, 모든 자료를 영구히 삭제하고 싶다면,
아래 버튼을 통해 계정 삭제 절차를 밟아야 합니다.

계정 삭제 후에는 데이터가 완전히 파기되므로, 복구 및 재연
결이 불가능합니다. 동일한 계정으로 재가입한 경우에도 복구
가 불가능 하니, 신중하게 결정해 주세요!
"""
        let attributedString = NSMutableAttributedString(string: labelText)
        label.text = labelText
        let findString = ["""
                          <마이페이지 - 프로필 편집 - 상대방과 연결 끊기> 를
                          통해 상대방과 연결을 끊을 수 있습니다.
                          """,
                          """
                          계정 삭제 후에는 데이터가 완전히 파기되므로, 복구 및 재연
                          결이 불가능합니다. 동일한 계정으로 재가입한 경우에도 복구
                          가 불가능 하니, 신중하게 결정해 주세요!
                          """
        ]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        for i in findString {
            if let range = label.text?.range(of: i) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.gray1,
                    .font: FontManager.shared.semiBold(ofSize: 14)
                ]
                let nsRange = NSRange(range, in: labelText)
                attributedString.addAttributes(attributes, range: nsRange)
            }
        }
        label.attributedText = attributedString
        
        return label
    }()
    
    let withdrawalBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("멜로미터 탈퇴하기", for: .normal)
        button.setTitleColor(.primary1, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 18)
        button.layer.cornerRadius = 25
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.48, x: 0, y: 0, blur: 16)
        button.layer.masksToBounds = false
        
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        withdrawalBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            exLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 31),
            exLabel.widthAnchor.constraint(equalToConstant: 330),

            withdrawalBtn.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            withdrawalBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            withdrawalBtn.widthAnchor.constraint(equalToConstant: 327),
            withdrawalBtn.heightAnchor.constraint(equalToConstant: 52),
        ])
        
    }
}
