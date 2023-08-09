//
//  DdayViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

// 기념일 화면 뷰컨트롤러
class DdayVC: UIViewController {

    private let dateFormat = DateFormatter()
    private let viewModel: DdayVM?
    let disposeBag = DisposeBag()
    
    init(viewModel: DdayVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dDayTableView.delegate = self
        dDayTableView.dataSource = self
        configure()
        setAutoLayout()
        setBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setBindings() {
        
        let input = DdayVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable(),
            addDdayBtnTapEvent: self.addDdayBarButton.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.firstDay
            .asDriver(onErrorJustReturn: "2023.00.00")
            .drive(onNext: {[weak self] text in
                self?.startDateLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.sinceFirstDay
            .asDriver(onErrorJustReturn: "1일")
            .drive(onNext: {[weak self] text in
                self?.countDateLabel.text = text
            })
            .disposed(by: disposeBag)
    }
    
    func dismissModalViewController() {
        dismiss(animated: true) {
            // 모달 뷰 컨트롤러가 dismiss된 후에 호출할 메서드를 호출
            self.viewWillAppear(true)// 원하는 메서드 호출
        }
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [topView, dDayTableView].forEach { view.addSubview($0) }
        setNavigationBar()
    }
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "기념일"
        navigationItem.rightBarButtonItem = addDdayBarButton
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
    
    private lazy var addDdayBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "plusIcon"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()
    
    
    // MARK: UI
    
    //상단 배경 뷰
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), alpha: 0.25, x: 3, y: 2, blur: 10)
        view.addSubview(dDayImageView)
        view.addSubview(nomalLabel)
        view.addSubview(countDateLabel)
        view.addSubview(startDateLabel)
        
        return view
    }()
    
    //로고 이미지
    let dDayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "topImage")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // 우리 함께한지 label
    private let nomalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "우리 함께한지"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    // 현재 D+ 날짜 label
    let countDateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .primary1
        label.font = FontManager.shared.semiBold(ofSize: 32)
        return label
    }()
    // 연애 시작일 날짜 label
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = ""
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    // 기념일 리스트 tableView
    let dDayTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DdayTableViewCell.self, forCellReuseIdentifier: "DdayTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return tableView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        topViewConstraints()
        dDayImageViewConstraints()
        labelConstraints()
        dDayTableViewConstraints()
    }
    
    
    private func topViewConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 9),
            topView.heightAnchor.constraint(equalToConstant: 340)
            
        ])
    }
    
    private func dDayImageViewConstraints() {
        dDayImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dDayImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 35),
            dDayImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -47),
            dDayImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 39),
            dDayImageView.heightAnchor.constraint(equalToConstant: 147)
        ])
    }
    
    
    private func labelConstraints() {
        nomalLabel.translatesAutoresizingMaskIntoConstraints = false
        countDateLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nomalLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            nomalLabel.topAnchor.constraint(equalTo: dDayImageView.bottomAnchor, constant: 13),
            nomalLabel.widthAnchor.constraint(equalToConstant: 87),
            nomalLabel.heightAnchor.constraint(equalToConstant: 19),
            
            countDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            countDateLabel.topAnchor.constraint(equalTo: nomalLabel.bottomAnchor, constant: 6),
            
            startDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            startDateLabel.topAnchor.constraint(equalTo: countDateLabel.bottomAnchor, constant: 16),
            
            
        ])
    }
    
    private func dDayTableViewConstraints() {
        dDayTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dDayTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            dDayTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            dDayTableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            dDayTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
    }
}

extension DdayVC: UITableViewDataSource, UITableViewDelegate {
    // 기념일 리스트 세팅
    func setDataDdayList() {
        // 기념일 날짜 계산하는 함수 호출
    }
    //기념일 리스트 tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DdayTableViewCell", for: indexPath) as? DdayTableViewCell else { return UITableViewCell() }
//        let target = Model.shared.dataDdayTableView[indexPath.row]
//        cell.titleLabel.text = target.aniName
//        cell.dateLabel.text = target.aniDate
//        cell.remainingDaysLabel.text = target.countDdays
        cell.selectionStyle = .none //셀 선택 색상 없애기

        //이전 셀들의 라벨 텍스트 색상 변경
//        if let anniversaryDate = dateFormat.date(from: target.aniDate) {
//            let comparisonResult = Calendar.current.compare(anniversaryDate, to: Date(), toGranularity: .day)
//
//            if comparisonResult == .orderedAscending { // 오늘 이전의 날짜
//                cell.titleLabel.textColor = .gray3
//                cell.dateLabel.textColor = .gray4
//                cell.remainingDaysLabel.textColor = .gray3
//            } else { // 오늘 이후의 날짜
//                cell.titleLabel.textColor = .gray1
//                cell.dateLabel.textColor = .gray2
//                cell.remainingDaysLabel.textColor = .gray1
//            }
//        } else {
//            // 기념일 날짜가 없는 경우 기본 색상 지정
//            cell.titleLabel.textColor = .gray2
//            cell.dateLabel.textColor = .gray2
//            cell.remainingDaysLabel.textColor = .gray2
//        }
        return cell
    }

    //첫번째 셀 변경
    func changeCell() {
//        let indexPath = IndexPath(row: Model.shared.cellIndex, section: 0)
//        dDayTableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }
}
