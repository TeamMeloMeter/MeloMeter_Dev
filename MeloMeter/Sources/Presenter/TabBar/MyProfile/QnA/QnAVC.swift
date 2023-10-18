//
//  QnAViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit
import RxSwift
import RxRelay
import RxGesture

class QnAVC: UIViewController {
    
    private let viewModel: QnAVM?
    private let disposeBag = DisposeBag()
    private var radioBtnArray: [UIButton] = []
    var selectedRadioBtn = BehaviorRelay<QnARadioBtn>(value: .auth)
    var cellData: [String] = []
    var selectedCellIndex = PublishRelay<(QnARadioBtn, Int)>()

    init(viewModel: QnAVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qnATableView.delegate = self
        self.qnATableView.dataSource = self
        radioBtnArray = [self.radioBtn, self.radioBtn1, self.radioBtn2,
                         self.radioBtn3]
         
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
        self.radioBtnBind()
        let input = QnAVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            radioBtnTapEvent: selectedRadioBtn.asObservable(),
            cellTapEvent: selectedCellIndex.asObservable()
        )
        
        guard let output = viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.titleStringData
            .bind(onNext: {[weak self] data in
                guard let self = self else{ return }
                self.cellData = data
                self.qnATableView.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
    
    func radioBtnBind() {
        self.radioBtn.rx.tap
            .map({ _ in
                self.radioBtnTapped(self.radioBtn)
                return QnARadioBtn.auth
            })
            .bind(to: self.selectedRadioBtn)
            .disposed(by: disposeBag)
        
        self.radioBtn1.rx.tap
            .map({ _ in
                self.radioBtnTapped(self.radioBtn1)
                return QnARadioBtn.backup
            })
            .bind(to: self.selectedRadioBtn)
            .disposed(by: disposeBag)
        
        self.radioBtn2.rx.tap
            .map({ _ in
                self.radioBtnTapped(self.radioBtn2)
                return QnARadioBtn.connection
            })
            .bind(to: self.selectedRadioBtn)
            .disposed(by: disposeBag)
        
        self.radioBtn3.rx.tap
            .map({ _ in
                self.radioBtnTapped(self.radioBtn3)
                return QnARadioBtn.withdraw
            })
            .bind(to: self.selectedRadioBtn)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [radioBtn, radioBtn1, radioBtn2, radioBtn3, qnATableView].forEach { view.addSubview($0) }
    }
    
    // MARK: Event
    func radioBtnTapped(_ sender: UIButton) {
        radioBtnArray.forEach { $0.isSelected = false; $0.backgroundColor = .gray5
            $0.titleLabel?.font = FontManager.shared.medium(ofSize: 14)}
        sender.isSelected = true
        sender.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        sender.backgroundColor = .primary1
    }

    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "자주묻는 질문"
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
    let radioBtn: UIButton = {
        let button = UIButton()
        button.setTitle("가입/인증", for: .normal)
        button.setTitleColor(.gray2, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.isSelected = true
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .primary1
        return button
    }()
    
    let radioBtn1: UIButton = {
        let button = UIButton()
        button.setTitle("백업/복구", for: .normal)
        button.setTitleColor(.gray2, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .gray5
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn2: UIButton = {
        let button = UIButton()
        button.setTitle("재연결", for: .normal)
        button.setTitleColor(.gray2, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .gray5
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn3: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴", for: .normal)
        button.setTitleColor(.gray2, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .gray5
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    
    // 질문 tableView
    let qnATableView: UITableView = {
        let tableView = UITableView()
        tableView.register(QnATableViewCell.self, forCellReuseIdentifier: "QnATableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 오토레이아웃
    private func setAutoLayout() {
        radioConstraints()
        qnATableViewConstraints()
    }
    
    private func radioConstraints() {
        radioBtn.translatesAutoresizingMaskIntoConstraints = false
        radioBtn1.translatesAutoresizingMaskIntoConstraints = false
        radioBtn2.translatesAutoresizingMaskIntoConstraints = false
        radioBtn3.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radioBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            radioBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            radioBtn.widthAnchor.constraint(equalToConstant: 86),
            radioBtn.heightAnchor.constraint(equalToConstant: 37),
           
            radioBtn1.leadingAnchor.constraint(equalTo: radioBtn.trailingAnchor, constant: 8),
            radioBtn1.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            radioBtn1.widthAnchor.constraint(equalToConstant: 86),
            radioBtn1.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn2.leadingAnchor.constraint(equalTo: radioBtn1.trailingAnchor, constant: 8),
            radioBtn2.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            radioBtn2.widthAnchor.constraint(equalToConstant: 69),
            radioBtn2.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn3.leadingAnchor.constraint(equalTo: radioBtn2.trailingAnchor, constant: 10),
            radioBtn3.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26),
            radioBtn3.widthAnchor.constraint(equalToConstant: 57),
            radioBtn3.heightAnchor.constraint(equalToConstant: 37),

        ])
    }
    
    private func qnATableViewConstraints() {
        qnATableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            qnATableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            qnATableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            qnATableView.topAnchor.constraint(equalTo: radioBtn3.bottomAnchor, constant: 31.5),
            qnATableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
           
        ])
    }
}

extension QnAVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QnATableViewCell", for: indexPath) as? QnATableViewCell else { return UITableViewCell() }
        let data = self.cellData[indexPath.row]
        cell.questionLabel.text = data
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedRadioBtn.take(1)
            .subscribe(onNext: { btn in
                self.selectedCellIndex.accept((btn, indexPath.row))
            })
            .disposed(by: disposeBag)
        
    }
}
