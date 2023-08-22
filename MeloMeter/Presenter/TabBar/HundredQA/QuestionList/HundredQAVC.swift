//
//  HundredQAVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class HundredQAVC: UIViewController {

    private let viewModel: HundredQAVM?
    let disposeBag = DisposeBag()
    var selectedCellIndex = PublishSubject<Int>()

    init(viewModel: HundredQAVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hundredQATableView.delegate = self
        hundredQATableView.dataSource = self
        configure()
        setAutoLayout()
        setBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.hundredQATableView.scrollToRow(at: self.indexPath, at: .top, animated: true)
    }
    
    func setBindings() {
        
        let input = HundredQAVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            cellTapEvent: self.selectedCellIndex.asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
       
        
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        setNavigationBar()
        [hundredQATableView, questionCountLabel].forEach { view.addSubview($0) }
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "백문백답"
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

    let questionCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1/2"
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 질문"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.textColor = .gray1
        return label
    }()
    
    lazy var hundredQATableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HundredQATableViewCell.self, forCellReuseIdentifier: "HundredQATableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 86
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let ourHundredQALabel: UILabel = {
        let label = UILabel()
        label.text = "우리의 백문백답"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.textColor = .gray1
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 오토레이아웃
    private func setAutoLayout() {
        todayLabel.translatesAutoresizingMaskIntoConstraints = false
        hundredQATableView.translatesAutoresizingMaskIntoConstraints = false
        ourHundredQALabel.translatesAutoresizingMaskIntoConstraints = false
        questionCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            questionCountLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            questionCountLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 35),

            hundredQATableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            hundredQATableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 28),
            hundredQATableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            hundredQATableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
        ])
    }
}

extension HundredQAVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 10
        }
        return 0
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 8, width: tableView.bounds.size.width - 32, height: 28)
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.textColor = .gray1
        if section == 0 {
            label.text = "오늘의 질문"
        } else if section == 1 {
            label.text = "우리의 백문백답"
        }
        headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 57))

        return spacerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HundredQATableViewCell", for: indexPath) as? HundredQATableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.newDotImage.isHidden = false
            }
            //let rowData = dataForSection0[indexPath.row]
            
        } else if indexPath.section == 1 {
            //let rowData = dataForSection1[indexPath.row]
            
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCellIndex.onNext(indexPath.row)
    }
    
}
