//
//  DetailNoticeVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/15.
//

import UIKit
import RxSwift

class DetailNoticeVC: UIViewController {
    
    private let viewModel: NoticeVM?
    private let disposeBag = DisposeBag()
    
    init(viewModel: NoticeVM) {
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
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    // MARK: Bindings
    func setBindings() {
        let input = NoticeVM.DetailInput(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        guard let output = viewModel?.detailTransform(input: input, disposeBag: self.disposeBag) else{ return }
        
        
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [titleLabel, infoLabel, lineView, scrollView].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
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
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "멜로미터에 오신 것을 환영합니다!"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "안내 | 23년 08월 15일"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    //구분선
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    //스크롤뷰
    lazy var scrollView: UIScrollView = {
        let scView = UIScrollView()
        scView.backgroundColor = .white
        scView.indicatorStyle = .black
        scView.addSubview(contentsView)
        return scView
    }()
    
    lazy var contentsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(contentsLabel)
        return view
    }()

    let contentsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "안녕하세요. 멜로미터입니다. \n\n회원 가입 시 입력하는 번호가 고객님의 멜로미터 아이디입니다. 아이디는 원활한 앱 사용을 위해~~ \n\n[계정 인증 방법]\n\n 가입 직후 발송된 멜로미터의 어쩌구 확인"
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            contentsView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            contentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            contentsLabel.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: 16),
            contentsLabel.topAnchor.constraint(equalTo: contentsView.topAnchor, constant: 30),
            contentsLabel.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor, constant: -16),
            
        ])
    }
}

