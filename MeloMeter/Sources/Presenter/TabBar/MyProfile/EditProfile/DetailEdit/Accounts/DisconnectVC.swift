//
//  DisconnectVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit
import RxSwift

class DisconnectVC: UIViewController {
    

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
            excuteBtnEvent: self.disconnectBtn.rx.tap
                .map({ .disconnect })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        
    }
   
    //MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [titleLabel, exLabel1, exLabel2, lineView, disconnectBtn].forEach { view.addSubview($0) }
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
    
    
    //MARK: UI
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방과의 연결을 끊기 전에 확인해 주세요!"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()
    
    private let exLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "• 두 분의 계정으로 앱 내 자료 열람 차단됨\n• 자료 보관기간 만료 시 기존 자료 영구 삭제"

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
        let labelText = "나와 상대방의 연결이 끊어지면 두 분이 업로드한 모든 자료(대화,기념일 등)의 열람이 차단되며, 기간 내 재연결을 하거나 백업 받은 파일로만 기존 자료를 확인 하실 수 있습니다.\n\n두 분의 자료를 복구할 수 있는 기간은 연결을 끊은 시점으로부터 30일입니다. 자료 복구를 원하신다면 자료 복구 기간 내에 시도해 주세요.\n\n재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."
        let attributedString = NSMutableAttributedString(string: labelText)
        label.text = labelText
        let findString = ["끊은 시점으로부터 30일입니다.", "재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
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
    
    let disconnectBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("연결끊기", for: .normal)
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
        exLabel1.translatesAutoresizingMaskIntoConstraints = false
        exLabel2.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        disconnectBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            exLabel1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel1.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 30),
            
            exLabel2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel2.topAnchor.constraint(equalTo: exLabel1.bottomAnchor, constant: 24),
            exLabel2.widthAnchor.constraint(equalToConstant: 298),

            disconnectBtn.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            disconnectBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            disconnectBtn.widthAnchor.constraint(equalToConstant: 327),
            disconnectBtn.heightAnchor.constraint(equalToConstant: 52),
        ])    }

}
