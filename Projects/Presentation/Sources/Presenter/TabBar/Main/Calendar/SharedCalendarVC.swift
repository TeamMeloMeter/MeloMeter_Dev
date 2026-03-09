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
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public final class SharedCalendarVC: UIViewController {

    private let viewModel: SharedCalendarVM
    private let disposeBag = DisposeBag()
    private let savePlanSubject = PublishSubject<DatePlanModel>()
    private let updatePlanSubject = PublishSubject<DatePlanModel>()
    private let deletePlanSubject = PublishSubject<String>()
    private let dateSelectedSubject = PublishSubject<DateComponents>()

    private var allPlans: [DatePlanModel] = []
    private var currentDayPlans: [DatePlanModel] = []
    private var currentMonthDate = Date()
    private var selectedDate = Date()
    private var days: [Date?] = []

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 26)
        label.textColor = .gray1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.regular(ofSize: 13)
        label.textColor = .gray2
        label.text = "약속과 추억을 한 화면에서 관리해요"
        return label
    }()

    private let previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .gray1
        return button
    }()

    private let nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray1
        return button
    }()

    private let summaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let insightCardView = CalendarInsightView()

    private let totalSummaryView = CalendarSummaryView(title: "이번 달 일정")
    private let todaySummaryView = CalendarSummaryView(title: "오늘 일정")
    private let completedSummaryView = CalendarSummaryView(title: "완료")

    private let weekDayStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        ["일", "월", "화", "수", "목", "금", "토"].forEach { day in
            let label = UILabel()
            label.text = day
            label.font = FontManager.shared.medium(ofSize: 13)
            label.textColor = day == "일" ? UIColor.systemRed : .gray2
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
        return stack
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 20)
        label.textColor = .gray1
        return label
    }()

    private let selectedDateDetailLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.regular(ofSize: 13)
        label.textColor = .gray2
        return label
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "이 날짜에는 아직 일정이 없어요.\n오른쪽 위 + 버튼으로 새 약속을 추가해보세요."
        label.font = FontManager.shared.regular(ofSize: 14)
        label.textColor = .gray2
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    public init(viewModel: SharedCalendarVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        bind()
        applyMonth(date: Date(), selectedDate: Date())
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureNavigationBar() {
        title = "Calendar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "인사이트",
            style: .plain,
            target: self,
            action: #selector(insightTapped)
        )
    }

    private func configureUI() {
        view.backgroundColor = .white

        summaryStackView.addArrangedSubview(totalSummaryView)
        summaryStackView.addArrangedSubview(todaySummaryView)
        summaryStackView.addArrangedSubview(completedSummaryView)

        view.addSubview(monthLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(previousMonthButton)
        view.addSubview(nextMonthButton)
        view.addSubview(summaryStackView)
        view.addSubview(insightCardView)
        view.addSubview(weekDayStack)
        view.addSubview(collectionView)
        view.addSubview(selectedDateLabel)
        view.addSubview(selectedDateDetailLabel)
        view.addSubview(emptyStateLabel)
        view.addSubview(tableView)

        tableView.register(CalendarPlanCell.self, forCellReuseIdentifier: CalendarPlanCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self

        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(4)
            make.leading.equalTo(monthLabel)
        }

        nextMonthButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }

        previousMonthButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalTo(nextMonthButton.snp.leading).offset(-4)
            make.width.height.equalTo(32)
        }

        summaryStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(82)
        }

        insightCardView.snp.makeConstraints { make in
            make.top.equalTo(summaryStackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(96)
        }

        weekDayStack.snp.makeConstraints { make in
            make.top.equalTo(insightCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(24)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekDayStack.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(360)
        }

        selectedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(18)
            make.leading.equalToSuperview().inset(20)
        }

        selectedDateDetailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(selectedDateLabel)
            make.trailing.equalToSuperview().inset(20)
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedDateLabel.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectedDateLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func bind() {
        let input = SharedCalendarVM.Input(
            viewWillAppear: rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in }.asObservable(),
            dateSelected: dateSelectedSubject.asObservable(),
            addBtnTap: navigationItem.rightBarButtonItem?.rx.tap.asObservable() ?? .empty(),
            savePlan: savePlanSubject.asObservable(),
            updatePlan: updatePlanSubject.asObservable(),
            deletePlan: deletePlanSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.allPlans
            .drive(onNext: { [weak self] plans in
                guard let self else { return }
                self.allPlans = plans.sorted {
                    ($0.scheduledDateValue() ?? .distantFuture) < ($1.scheduledDateValue() ?? .distantFuture)
                }
                self.refreshForCurrentSelection()
            })
            .disposed(by: disposeBag)

        output.currentDayPlans
            .drive(onNext: { [weak self] plans in
                guard let self else { return }
                self.currentDayPlans = plans
                self.selectedDateDetailLabel.text = "총 \(plans.count)개"
                self.emptyStateLabel.isHidden = plans.isEmpty == false
                self.tableView.isHidden = plans.isEmpty
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.planSaved
            .emit(onNext: { [weak self] in
                self?.showSavedToast(message: "일정을 저장했어요.")
            })
            .disposed(by: disposeBag)

        output.planUpdated
            .emit(onNext: { [weak self] in
                self?.showSavedToast(message: "일정을 수정했어요.")
            })
            .disposed(by: disposeBag)

        output.planDeleted
            .emit(onNext: { [weak self] in
                self?.showSavedToast(message: "일정을 삭제했어요.")
            })
            .disposed(by: disposeBag)

        previousMonthButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.moveMonth(by: -1)
            })
            .disposed(by: disposeBag)

        nextMonthButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.moveMonth(by: 1)
            })
            .disposed(by: disposeBag)

        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: selectedDate))
    }

    @objc private func addTapped() {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        presentAddSchedule(date: components)
    }

    @objc private func todayTapped() {
        applyMonth(date: Date(), selectedDate: Date())
        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: Date()))
    }

    @objc private func insightTapped() {
        let viewController = CalendarInsightVC(
            monthDate: currentMonthDate,
            plans: allPlans,
            records: DateRecordStore.shared.items(coupleId: UserDefaults.standard.string(forKey: "coupleID"))
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func moveMonth(by value: Int) {
        guard let movedDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonthDate) else { return }
        let targetDate: Date
        if Calendar.current.isDate(movedDate, equalTo: selectedDate, toGranularity: .month) {
            targetDate = selectedDate
        } else {
            targetDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: movedDate)) ?? movedDate
        }
        applyMonth(date: movedDate, selectedDate: targetDate)
        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: targetDate))
    }

    private func applyMonth(date: Date, selectedDate: Date) {
        currentMonthDate = date
        self.selectedDate = selectedDate
        monthLabel.text = date.toString(format: "yyyy년 M월")
        selectedDateLabel.text = selectedDate.toString(format: "M월 d일 일정")
        days = generateDaysInMonth(for: date)
        collectionView.reloadData()
        updateSummaryViews()
    }

    private func refreshForCurrentSelection() {
        selectedDateLabel.text = selectedDate.toString(format: "M월 d일 일정")
        updateSummaryViews()
        collectionView.reloadData()
        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: selectedDate))
    }

    private func updateSummaryViews() {
        let summary = allPlans.monthSummary(for: currentMonthDate)
        let insight = DateRecordStore.shared.monthInsight(
            for: currentMonthDate,
            coupleId: UserDefaults.standard.string(forKey: "coupleID")
        )
        totalSummaryView.update(value: "\(summary.totalCount)")
        todaySummaryView.update(value: "\(summary.todayCount)")
        completedSummaryView.update(value: "\(summary.completedCount)")
        insightCardView.configure(insight: insight)
    }

    private func generateDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var result: [Date?] = Array(repeating: nil, count: max(0, firstWeekday - 1))

        for day in range {
            if let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                result.append(currentDate)
            }
        }

        while result.count < 42 {
            result.append(nil)
        }

        return result
    }

    private func plans(for date: Date) -> [DatePlanModel] {
        allPlans.plans(on: date)
    }

    private func presentAddSchedule(date: DateComponents) {
        let viewController = AddScheduleVC(initialDate: Calendar.current.date(from: date))
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 520 }]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
        }

        viewController.onSave = { [weak self] plan in
            self?.savePlanSubject.onNext(plan)
        }

        present(viewController, animated: true)
    }

    private func openPlanOnMap(_ plan: DatePlanModel) {
        NotificationCenter.default.post(
            name: .datePlanSelectedFromCalendar,
            object: nil,
            userInfo: ["uuid": plan.uuid, "action": DatePlanMapAction.focus.rawValue]
        )
        tabBarController?.selectedIndex = 1
        navigationController?.popViewController(animated: true)
    }

    private func createRecord(for plan: DatePlanModel) {
        if let record = DateRecordStore.shared.item(planUUID: plan.uuid, coupleId: UserDefaults.standard.string(forKey: "coupleID")) {
            presentRecordDetail(record)
            return
        }
        NotificationCenter.default.post(
            name: .datePlanSelectedFromCalendar,
            object: nil,
            userInfo: ["uuid": plan.uuid, "action": DatePlanMapAction.record.rawValue]
        )
        tabBarController?.selectedIndex = 1
        navigationController?.popViewController(animated: true)
    }

    private func presentRecordDetail(_ record: DateRecordItem) {
        let viewController = CalendarRecordDetailSheetVC(record: record)
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(identifier: .init("calendar-record-detail")) { context in
                    min(360, context.maximumDetentValue)
                }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = .init("calendar-record-detail")
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true)
    }

    private func presentEditSheet(for plan: DatePlanModel) {
        let viewController = CalendarDatePlanEditSheetVC(plan: plan) { [weak self] updatedPlan in
            self?.updatePlanSubject.onNext(updatedPlan)
        }
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(identifier: .init("calendar-plan-edit")) { context in
                    min(360, context.maximumDetentValue)
                }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = .init("calendar-plan-edit")
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true)
    }

    private func confirmDelete(plan: DatePlanModel) {
        let alert = UIAlertController(title: "일정을 삭제할까요?", message: "삭제한 일정은 복구할 수 없어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.deletePlanSubject.onNext(plan.uuid)
        }))
        present(alert, animated: true)
    }

    private func showSavedToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}

extension SharedCalendarVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }

        guard let date = days[indexPath.item] else {
            cell.configureEmpty()
            return cell
        }

        cell.configure(
            date: date,
            plans: plans(for: date),
            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
            isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonthDate, toGranularity: .month),
            coupleId: UserDefaults.standard.string(forKey: "coupleID")
        )
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = days[indexPath.item] else { return }
        selectedDate = date
        selectedDateLabel.text = date.toString(format: "M월 d일 일정")
        collectionView.reloadData()
        dateSelectedSubject.onNext(Calendar.current.dateComponents([.year, .month, .day], from: date))
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.bounds.width / 7)
        return CGSize(width: width, height: 52)
    }
}

extension SharedCalendarVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentDayPlans.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CalendarPlanCell.identifier, for: indexPath) as? CalendarPlanCell else {
            return UITableViewCell()
        }
        let plan = currentDayPlans[indexPath.row]
        cell.configure(plan: plan)
        cell.onMapButtonTap = { [weak self] in
            self?.openPlanOnMap(plan)
        }
        cell.onEditButtonTap = { [weak self] in
            self?.presentEditSheet(for: plan)
        }
        cell.onDeleteButtonTap = { [weak self] in
            self?.confirmDelete(plan: plan)
        }
        cell.onRecordButtonTap = { [weak self] in
            self?.createRecord(for: plan)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openPlanOnMap(currentDayPlans[indexPath.row])
    }
}

private final class CalendarSummaryView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.regular(ofSize: 12)
        label.textColor = .gray2
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.bold(ofSize: 24)
        label.textColor = .gray1
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .gray5
        layer.cornerRadius = 18
        titleLabel.text = title

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(14)
        }

        valueLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(14)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: String) {
        valueLabel.text = value
    }
}

private final class CalendarInsightView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 달 추억 인사이트"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.textColor = .gray1
        return label
    }()

    private let recordLabel = CalendarInsightMetricView(title: "기록")
    private let favoriteLabel = CalendarInsightMetricView(title: "재방문")
    private let satisfactionLabel = CalendarInsightMetricView(title: "평균 만족도")

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray5
        layer.cornerRadius = 20

        let metricsStack = UIStackView(arrangedSubviews: [recordLabel, favoriteLabel, satisfactionLabel])
        metricsStack.axis = .horizontal
        metricsStack.distribution = .fillEqually

        addSubview(titleLabel)
        addSubview(metricsStack)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        metricsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(insight: DateRecordMonthInsight) {
        recordLabel.update(value: "\(insight.recordCount)")
        favoriteLabel.update(value: "\(insight.favoriteCount)")
        let text = insight.recordCount == 0 ? "-" : String(format: "%.1f", insight.averageSatisfaction)
        satisfactionLabel.update(value: text)
    }
}

private final class CalendarInsightMetricView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = FontManager.shared.regular(ofSize: 12)
        titleLabel.textColor = .gray2
        valueLabel.font = FontManager.shared.bold(ofSize: 18)
        valueLabel.textColor = .primary2

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: String) {
        valueLabel.text = value
    }
}

private final class CalendarDatePlanEditSheetVC: UIViewController {
    private let plan: DatePlanModel
    private let onSave: (DatePlanModel) -> Void

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "예약 시간 수정"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 16)
        button.backgroundColor = .primary1
        button.layer.cornerRadius = 12
        return button
    }()

    init(plan: DatePlanModel, onSave: @escaping (DatePlanModel) -> Void) {
        self.plan = plan
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let scheduledDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) {
            datePicker.date = scheduledDate
        }
        [titleLabel, datePicker, saveButton].forEach(view.addSubview)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    @objc private func saveTapped() {
        let hasActivity = plan.checkIns.isEmpty == false || plan.arrivalRecords.isEmpty == false
        let updatedPlan = DatePlanModel(
            uuid: plan.uuid,
            name: plan.name,
            memo: plan.memo,
            mapX: plan.mapX,
            mapY: plan.mapY,
            roadAddress: plan.roadAddress,
            address: plan.address,
            scheduledAt: datePicker.date.toString(type: .yearToSecond),
            createdAt: plan.createdAt,
            createdBy: plan.createdBy,
            notifyEnabled: plan.notifyEnabled,
            radiusMeters: plan.radiusMeters,
            dwellSeconds: plan.dwellSeconds,
            checkIns: hasActivity ? [:] : plan.checkIns,
            arrivalRecords: hasActivity ? [:] : plan.arrivalRecords,
            isOnTime: hasActivity ? nil : plan.isOnTime,
            isCompleted: hasActivity ? nil : plan.isCompleted
        )
        onSave(updatedPlan)
        dismiss(animated: true)
    }
}

private final class CalendarRecordDetailSheetVC: UIViewController {
    private let record: DateRecordItem

    init(record: DateRecordItem) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.font = FontManager.shared.bold(ofSize: 20)
        titleLabel.textColor = .gray1
        titleLabel.text = record.title

        let categoryBadge = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        categoryBadge.font = FontManager.shared.semiBold(ofSize: 11)
        categoryBadge.textColor = .primary2
        categoryBadge.backgroundColor = UIColor.primary1.withAlphaComponent(0.14)
        categoryBadge.layer.cornerRadius = 12
        categoryBadge.layer.masksToBounds = true
        categoryBadge.text = record.category

        let locationLabel = UILabel()
        locationLabel.font = FontManager.shared.medium(ofSize: 14)
        locationLabel.textColor = .gray2
        locationLabel.text = record.locationName

        let memoLabel = UILabel()
        memoLabel.font = FontManager.shared.regular(ofSize: 14)
        memoLabel.textColor = .gray1
        memoLabel.numberOfLines = 0
        memoLabel.text = record.memo

        let metaLabel = UILabel()
        metaLabel.font = FontManager.shared.medium(ofSize: 13)
        metaLabel.textColor = .gray2
        metaLabel.text = "만족도 \(record.satisfaction)/3" + (record.isFavorite ? " · 다시 가고 싶은 장소" : "")

        let imageStack = UIStackView()
        imageStack.axis = .horizontal
        imageStack.spacing = 8
        imageStack.distribution = .fillEqually
        imageStack.isHidden = record.imageDatas.isEmpty

        record.imageDatas.prefix(3).forEach { data in
            let imageView = UIImageView()
            imageView.image = UIImage(data: data)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 14
            imageStack.addArrangedSubview(imageView)
        }

        [titleLabel, categoryBadge, locationLabel, memoLabel, imageStack, metaLabel].forEach(view.addSubview)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        categoryBadge.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryBadge.snp.bottom).offset(14)
            make.leading.trailing.equalTo(titleLabel)
        }
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(14)
            make.leading.trailing.equalTo(titleLabel)
        }
        imageStack.snp.makeConstraints { make in
            make.top.equalTo(memoLabel.snp.bottom).offset(14)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(record.imageDatas.isEmpty ? 0 : 88)
        }
        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(imageStack.snp.bottom).offset(18)
            make.leading.trailing.equalTo(titleLabel)
        }
    }
}

private final class CalendarInsightVC: UIViewController {
    private let monthDate: Date
    private let plans: [DatePlanModel]
    private let records: [DateRecordItem]

    init(monthDate: Date, plans: [DatePlanModel], records: [DateRecordItem]) {
        self.monthDate = monthDate
        self.plans = plans
        self.records = records
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Monthly Insight"

        let summary = plans.monthSummary(for: monthDate)
        let insight = DateRecordStore.shared.monthInsight(for: monthDate, coupleId: UserDefaults.standard.string(forKey: "coupleID"))

        let titleLabel = UILabel()
        titleLabel.font = FontManager.shared.bold(ofSize: 28)
        titleLabel.textColor = .gray1
        titleLabel.text = monthDate.toString(format: "M월 기록")

        let heroCard = CalendarInsightView()
        heroCard.configure(insight: insight)

        let completionCard = CalendarInsightSummaryCard(title: "완료된 데이트", value: "\(summary.completedCount)회", tintColor: .primary2)
        let totalCard = CalendarInsightSummaryCard(title: "전체 일정", value: "\(summary.totalCount)개", tintColor: .gray1)
        let revisitCard = CalendarInsightSummaryCard(title: "다시 가고 싶은 장소", value: "\(insight.favoriteCount)곳", tintColor: .point1)
        let categoryCard = CalendarInsightSummaryCard(title: "가장 많은 카테고리", value: insight.topCategory ?? "-", tintColor: .primary1)

        let stack = UIStackView(arrangedSubviews: [completionCard, totalCard, revisitCard, categoryCard])
        stack.axis = .vertical
        stack.spacing = 12

        [titleLabel, heroCard, stack].forEach(view.addSubview)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        heroCard.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(112)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(heroCard.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

private final class CalendarInsightSummaryCard: UIView {
    init(title: String, value: String, tintColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = .gray5
        layer.cornerRadius = 18

        let titleLabel = UILabel()
        titleLabel.font = FontManager.shared.medium(ofSize: 13)
        titleLabel.textColor = .gray2
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = FontManager.shared.bold(ofSize: 20)
        valueLabel.textColor = tintColor
        valueLabel.text = value

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class CalendarDayCell: UICollectionViewCell {
    static let identifier = "CalendarDayCell"

    private let selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primary1.withAlphaComponent(0.12)
        view.layer.cornerRadius = 14
        view.isHidden = true
        return view
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    private let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.isHidden = true
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.bold(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .gray2
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(indicatorView)
        contentView.addSubview(countLabel)

        selectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.centerX.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(30)
        }

        dayLabel.snp.makeConstraints { make in
            make.centerX.equalTo(selectionView)
            make.centerY.equalTo(selectionView)
        }

        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(selectionView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(6)
        }

        countLabel.snp.makeConstraints { make in
            make.top.equalTo(indicatorView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureEmpty() {
        dayLabel.text = nil
        indicatorView.isHidden = true
        countLabel.isHidden = true
        selectionView.isHidden = true
    }

    func configure(date: Date, plans: [DatePlanModel], isSelected: Bool, isCurrentMonth: Bool, coupleId: String?) {
        let calendar = Calendar.current
        dayLabel.text = "\(calendar.component(.day, from: date))"
        selectionView.isHidden = isSelected == false

        if calendar.isDateInToday(date) {
            dayLabel.textColor = .primary2
            dayLabel.font = FontManager.shared.bold(ofSize: 14)
        } else if calendar.component(.weekday, from: date) == 1 {
            dayLabel.textColor = isCurrentMonth ? .systemRed : UIColor.systemRed.withAlphaComponent(0.4)
            dayLabel.font = FontManager.shared.medium(ofSize: 14)
        } else {
            dayLabel.textColor = isCurrentMonth ? .gray1 : .gray3
            dayLabel.font = FontManager.shared.medium(ofSize: 14)
        }

        if let firstPlan = plans.first {
            indicatorView.isHidden = false
            let record = DateRecordStore.shared.item(planUUID: firstPlan.uuid, coupleId: coupleId)
            countLabel.isHidden = plans.count < 2 && record == nil
            indicatorView.backgroundColor = color(for: firstPlan, record: record)
            countLabel.text = plans.count >= 2 ? "+\(plans.count - 1)" : record.map { "\($0.satisfaction)" }
            countLabel.textColor = color(for: firstPlan, record: record)
        } else {
            indicatorView.isHidden = true
            countLabel.isHidden = true
            countLabel.text = nil
        }
    }

    private func color(for plan: DatePlanModel, record: DateRecordItem?) -> UIColor {
        guard let record else { return plan.displayStatus().tintColor }
        switch record.satisfaction {
        case 3:
            return .point1
        case 2:
            return .primary1
        default:
            return .gray2
        }
    }
}

private final class CalendarPlanCell: UITableViewCell {
    static let identifier = "CalendarPlanCell"

    var onMapButtonTap: (() -> Void)?
    var onEditButtonTap: (() -> Void)?
    var onDeleteButtonTap: (() -> Void)?
    var onRecordButtonTap: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.applyShadow(color: .gray1, alpha: 0.08, x: 0, y: 6, blur: 18)
        return view
    }()

    private let statusBadge = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.textColor = .gray1
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 13)
        label.textColor = .gray2
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.regular(ofSize: 13)
        label.textColor = .gray2
        label.numberOfLines = 2
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .gray2
        label.isHidden = true
        return label
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.isHidden = true
        imageView.backgroundColor = .gray5
        return imageView
    }()

    private let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("지도에서 보기", for: .normal)
        button.setTitleColor(.primary2, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 13)
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("시간 수정", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 13)
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 13)
        return button
    }()

    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("기록 만들기", for: .normal)
        button.setTitleColor(.point1, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 13)
        button.isHidden = true
        return button
    }()

    private let recordBadge = PaddingLabel(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        statusBadge.font = FontManager.shared.semiBold(ofSize: 11)
        statusBadge.layer.cornerRadius = 12
        statusBadge.layer.masksToBounds = true
        statusBadge.textAlignment = .center

        contentView.addSubview(cardView)
        cardView.addSubview(statusBadge)
        cardView.addSubview(titleLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(metaLabel)
        cardView.addSubview(thumbnailImageView)
        [mapButton, editButton, deleteButton, recordButton, recordBadge].forEach(cardView.addSubview)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-6)
        }

        statusBadge.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadge.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(recordBadge.snp.leading).offset(-8)
        }

        recordBadge.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
        }

        mapButton.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(54)
        }

        editButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(editButton.snp.trailing).offset(12)
            make.centerY.equalTo(editButton)
        }

        recordButton.snp.makeConstraints { make in
            make.leading.equalTo(editButton)
            make.bottom.equalToSuperview().inset(12)
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(thumbnailImageView.snp.leading).offset(-10)
        }

        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(addressLabel)
            make.bottom.lessThanOrEqualTo(editButton.snp.top).offset(-10)
        }

        mapButton.addTarget(self, action: #selector(didTapMapButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)

        recordBadge.font = FontManager.shared.semiBold(ofSize: 10)
        recordBadge.textColor = .point1
        recordBadge.backgroundColor = UIColor.point1.withAlphaComponent(0.2)
        recordBadge.layer.cornerRadius = 10
        recordBadge.layer.masksToBounds = true
        recordBadge.text = "기록 있음"
        recordBadge.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(plan: DatePlanModel) {
        let status = plan.displayStatus()
        statusBadge.text = status.title
        statusBadge.textColor = status.tintColor
        statusBadge.backgroundColor = status.backgroundColor
        titleLabel.text = plan.name
        timeLabel.text = plan.timeText()
        addressLabel.text = plan.address.isEmpty ? plan.memo : plan.address
        let record = DateRecordStore.shared.item(planUUID: plan.uuid, coupleId: UserDefaults.standard.string(forKey: "coupleID"))
        let hasRecord = record != nil
        let isCompleted = plan.isCompleted == true
        recordButton.isHidden = isCompleted == false
        recordButton.setTitle(hasRecord ? "기록 보기" : "기록 만들기", for: .normal)
        editButton.isHidden = isCompleted
        deleteButton.isHidden = isCompleted
        recordBadge.isHidden = hasRecord == false
        if let record {
            metaLabel.isHidden = false
            metaLabel.text = "만족도 \(record.satisfaction)/3" + (record.isFavorite ? " · 다시 가고 싶은 장소" : "")
            if let firstImageData = record.imageDatas.first {
                thumbnailImageView.isHidden = false
                thumbnailImageView.image = UIImage(data: firstImageData)
            } else {
                thumbnailImageView.isHidden = true
                thumbnailImageView.image = nil
            }
        } else {
            metaLabel.isHidden = true
            metaLabel.text = nil
            thumbnailImageView.isHidden = true
            thumbnailImageView.image = nil
        }
    }

    @objc private func didTapMapButton() {
        onMapButtonTap?()
    }

    @objc private func didTapEditButton() {
        onEditButtonTap?()
    }

    @objc private func didTapDeleteButton() {
        onDeleteButtonTap?()
    }

    @objc private func didTapRecordButton() {
        onRecordButtonTap?()
    }
}

private final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
