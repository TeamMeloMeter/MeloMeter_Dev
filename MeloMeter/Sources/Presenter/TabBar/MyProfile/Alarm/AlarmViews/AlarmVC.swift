//
//  alarmViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class AlarmVC: UIViewController {
    
    private let viewModel: AlarmVM?
    let disposeBag = DisposeBag()
    var alarmDataList: [AlarmData] = []
    
    init(viewModel: AlarmVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmTableView.delegate = self
        alarmTableView.dataSource = self
        configure()
        setAutoLayout()
        setBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setBindings() {
        let input = AlarmVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
      
        output.alarmList
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { alarmList in
                self.alarmDataList = alarmList.reversed()
                self.alarmTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        setNavigationBar()
        [alarmTableView].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "알림"
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
    let alarmTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "AlarmTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return tableView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 오토레이아웃
    private func setAutoLayout() {
        alarmTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alarmTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            alarmTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 28),
            alarmTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            alarmTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension AlarmVC: UITableViewDataSource, UITableViewDelegate {
    // 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmDataList.count
    }
    // 셀에 데이터넣기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as? AlarmTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.alarmView.layer.applyShadow(color: UIColor.primary1, alpha: 0.25, x: 0, y: 2, blur: 18)
        }else {
            cell.alarmView.layer.applyShadow(color: #colorLiteral(red: 0.5137254902, green: 0.5058823529, blue: 0.5058823529, alpha: 1), alpha: 0.1, x: 0, y: 2, blur: 20)
        }
        
        cell.alarmTitleLabel.text = self.alarmDataList[indexPath.row].day
        cell.alarmSubtitleLabel.text = self.alarmDataList[indexPath.row].text
        cell.alarmImageView.image = UIImage(named: self.alarmDataList[indexPath.row].icon)
        
        return cell
    }
}

