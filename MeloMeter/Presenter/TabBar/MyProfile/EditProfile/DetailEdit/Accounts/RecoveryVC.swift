//
//  RecoveryVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit
import RxSwift

class RecoveryVC: UIViewController {
    
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
            excuteBtnEvent: self.recoveryBtn.rx.tap
                .map({ .recovery })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        
    }
    
    // MARK: Event

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
    
    // MARK: UI
    lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), alpha: 0.25, x: 0, y: 2, blur: 8)

        return view
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방과 연결이 끊어졌어요"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()
    
    private let namesLabel: UILabel = {
        let label = UILabel()
        label.text = "소희&제훈"
        label.font = FontManager.shared.semiBold(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private let exLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "• 연결 끊김 : 2023.05.15\n• 복구 가능한 기간 : 2023.06.15 까지"

        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.font = FontManager.shared.semiBold(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private let exLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        let labelText = "나와 상대방의 연결이 끊어지면 두 분이 업로드한 모든 자료(대화,기념일 등)의 열람이 차단되며, 기간 내 재연결을 하거나 백업 받은 파일로만 기존 자료를 확인 하실 수 있습니다.\n\n재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."
        let attributedString = NSMutableAttributedString(string: labelText)
        label.text = labelText
        let findString = ["재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."]
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
    
    let recoveryBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("자료 복구 신청하기", for: .normal)
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
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [infoView, titleLabel, namesLabel, exLabel1, exLabel2, lineView, recoveryBtn].forEach { view.addSubview($0) }
    }
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        exLabel1.translatesAutoresizingMaskIntoConstraints = false
        exLabel2.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        recoveryBtn.translatesAutoresizingMaskIntoConstraints = false
        namesLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            infoView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            infoView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            infoView.widthAnchor.constraint(equalToConstant: 343),
            infoView.heightAnchor.constraint(equalToConstant: 130),
            
            namesLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 25),
            namesLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 24),

            exLabel1.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            exLabel1.topAnchor.constraint(equalTo: namesLabel.bottomAnchor, constant: 2),
            
            exLabel2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 27),
            exLabel2.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 30),
            exLabel2.widthAnchor.constraint(equalToConstant: 298),

            recoveryBtn.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            recoveryBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            recoveryBtn.widthAnchor.constraint(equalToConstant: 327),
            recoveryBtn.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

  
}
