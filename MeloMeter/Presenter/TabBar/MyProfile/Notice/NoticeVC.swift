//
//  NoticeViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit
import RxSwift
import RxRelay
import RxGesture

class NoticeVC: UIViewController {
    
    private let viewModel: NoticeVM?
    private let disposeBag = DisposeBag()
    var selectedCellIndex = PublishSubject<Int>()
    
    init(viewModel: NoticeVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noticeTableView.delegate = self
        self.noticeTableView.dataSource = self
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
        let input = NoticeVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            cellTapEvent: selectedCellIndex.asObserver()
        )
        
        guard let output = viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [noticeTableView].forEach { view.addSubview($0) }
    }

    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "공지사항"
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
    let noticeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 108
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        dDayTableViewConstraints()
    }
    
    private func dDayTableViewConstraints() {
        noticeTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            noticeTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            noticeTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            noticeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            noticeTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension NoticeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as? NoticeTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCellIndex.onNext(indexPath.row)
    }
}
