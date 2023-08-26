//
//  AnswerViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit
import RxSwift
import RxRelay
import RxGesture

class DetailQnAVC: UIViewController {
    
    private let viewModel: QnAVM?
    private let disposeBag = DisposeBag()
    var cellData: [String] = []

    init(viewModel: QnAVM, title: String, contents: String) {
        self.viewModel = viewModel
        self.titleLabel.text = title
        self.answerLabel.text = contents
        super.init(nibName: nil, bundle: nil)
        self.setLabel()

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
    
    // MARK: Bindings
    func setBindings() {
        let input = QnAVM.DetailInput(
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        self.viewModel?.detailTransform(input: input, disposeBag: self.disposeBag)
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [titleLabel, lineView, scrollView].forEach { view.addSubview($0) }
    }
    func setLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let attributedText = NSMutableAttributedString(string: self.answerLabel.text ?? "")
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        self.answerLabel.attributedText = attributedText

        let attributedText1 = NSMutableAttributedString(string: self.titleLabel.text ?? "")
        attributedText1.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText1.length))
        self.titleLabel.attributedText = attributedText1
    }
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = ""
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
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scView = UIScrollView()
        scView.backgroundColor = .white
        scView.indicatorStyle = .black
        scView.addSubview(answerContentView)

        return scView
    }()
    
    lazy var answerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(answerLabel)
        return view
    }()

    let answerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
       
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        answerContentView.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            lineView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            answerContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            answerContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            answerContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            answerContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            answerContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            answerLabel.leadingAnchor.constraint(equalTo: answerContentView.leadingAnchor, constant: 20),
            answerLabel.topAnchor.constraint(equalTo: answerContentView.topAnchor, constant: 45),

        ])
        
    }
    
}
