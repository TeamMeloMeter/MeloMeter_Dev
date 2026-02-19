//
//  SharedCalendarVC.swift
//  Presentation
//
//  Created by OpenCode on 2026/01/14.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Domain
import Core

public class SharedCalendarVC: UIViewController {
    
    private let viewModel: SharedCalendarVM
    private let disposeBag = DisposeBag()
    private let savePlanSubject = PublishSubject<DatePlanModel>()
    
    // Data Source
    private var allPlans: [DatePlanModel] = []
    private var currentMonthDate = Date()
    private var days: [Date?] = [] // nil for empty slots
    
    // MARK: - UI Components
    
    private let headerView = UIView()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 24)
        label.textColor = .black
        label.text = "2025년 5월"
        return label
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let weekDayStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        let days = ["일", "월", "화", "수", "목", "금", "토"]
        for day in days {
            let label = UILabel()
            label.text = day
            label.font = FontManager.shared.medium(ofSize: 14)
            label.textColor = .gray2
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .black
        label.text = "오늘"
        return label
    }()
    
    private let tableView = UITableView()
    
    // Date Selection
    private var selectedDate = Date()
    private let dateSelectedSubject = PublishSubject<DateComponents>()

    public init(viewModel: SharedCalendarVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        
        // Initial setup
        updateCalendar(for: Date())
        
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc private func addTapped() {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        presentAddSchedule(date: components)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(headerView)
        headerView.addSubview(monthLabel)
        headerView.addSubview(searchButton)
        headerView.addSubview(addButton)
        
        view.addSubview(weekDayStack)
        view.addSubview(collectionView)
        view.addSubview(todayLabel)
        view.addSubview(tableView)
        
        // Layout
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        monthLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        weekDayStack.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekDayStack.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(350) 
        }
        
        todayLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(todayLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlanCell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    private func bind() {
        // ViewModel Input
        let input = SharedCalendarVM.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in }.asObservable(),
            dateSelected: dateSelectedSubject.asObservable(),
            addBtnTap: addButton.rx.tap.asObservable(),
            savePlan: savePlanSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.allPlans
            .drive(onNext: { [weak self] plans in
                self?.allPlans = plans
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.currentDayPlans
            .drive(tableView.rx.items(cellIdentifier: "PlanCell")) { index, plan, cell in
                var config = cell.defaultContentConfiguration()
                config.text = plan.name
                // 시간 포맷은 추후 개선 필요
                let timeString = plan.scheduledAt.components(separatedBy: " ").last ?? ""
                config.secondaryText = "\(timeString) • \(plan.memo)"
                config.image = UIImage(systemName: "circle.fill")
                config.imageProperties.tintColor = .primary1
                cell.contentConfiguration = config
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        // Initial selection
        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: Date()))
    }
    
    private func updateCalendar(for date: Date) {
        currentMonthDate = date
        
        // 날짜 포맷팅 (임시로 DateFormatter 사용)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        monthLabel.text = formatter.string(from: date)
        
        // Calculate days
        days = generateDaysInMonth(for: date)
        collectionView.reloadData()
        
        // Update Today Label
        formatter.dateFormat = "yyyy.MM.dd"
        todayLabel.text = "오늘(\(formatter.string(from: Date())))"
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 = Sunday
        let totalDays = range.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...totalDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Fill remaining cells to make it a full grid (optional)
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func presentAddSchedule(date: DateComponents) {
        let vc = AddScheduleVC()
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in return 500 }]
            } else {
                sheet.detents = [.large()]
            }
        }
        
        vc.onSave = { [weak self] plan in
            self?.savePlanSubject.onNext(plan)
        }
        
        present(vc, animated: true)
    }
}

// MARK: - CollectionView Delegate & DataSource
extension SharedCalendarVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        
        if let date = days[indexPath.item] {
            cell.configure(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
            
            // Filter plans for this date
            let dayPlans = allPlans.filter { plan in
                guard let planDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) else { return false }
                return Calendar.current.isDate(planDate, inSameDayAs: date)
            }
            cell.setPlans(dayPlans)
        } else {
            cell.configureEmpty()
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        let height: CGFloat = 80 // Adjust based on design
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = days[indexPath.item] else { return }
        selectedDate = date
        collectionView.reloadData() // Refresh selection UI
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateSelectedSubject.onNext(components)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        todayLabel.text = "선택된 날짜(\(formatter.string(from: date)))"
    }
}

// MARK: - CalendarDayCell
class CalendarDayCell: UICollectionViewCell {
    static let identifier = "CalendarDayCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let selectionCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .primary1
        view.layer.cornerRadius = 15
        view.isHidden = true
        return view
    }()
    
    private let planStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionCircle)
        contentView.addSubview(dayLabel)
        contentView.addSubview(planStack)
        
        selectionCircle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        dayLabel.snp.makeConstraints { make in
            make.center.equalTo(selectionCircle)
        }
        
        planStack.snp.makeConstraints { make in
            make.top.equalTo(selectionCircle.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(2)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureEmpty() {
        dayLabel.text = ""
        selectionCircle.isHidden = true
        planStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(date: Date, isSelected: Bool) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        if isSelected {
            selectionCircle.isHidden = false
            dayLabel.textColor = .white
        } else {
            selectionCircle.isHidden = true
            // Check for Sunday
            if calendar.component(.weekday, from: date) == 1 {
                dayLabel.textColor = .red
            } else {
                dayLabel.textColor = .black
            }
            
            // Check for Today
            if calendar.isDateInToday(date) {
                dayLabel.textColor = .primary1
                dayLabel.font = FontManager.shared.bold(ofSize: 14)
            } else {
                dayLabel.font = FontManager.shared.medium(ofSize: 14)
            }
        }
    }
    
    func setPlans(_ plans: [DatePlanModel]) {
        planStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, plan) in plans.enumerated() {
            if index >= 2 { break } // Max 2 plans shown
            
            let label = UILabel()
            label.text = plan.name
            label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            label.textColor = .black
            label.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0) // Light yellow like in image
            label.textAlignment = .center
            label.layer.cornerRadius = 4
            label.clipsToBounds = true
            planStack.addArrangedSubview(label)
        }
    }
}
