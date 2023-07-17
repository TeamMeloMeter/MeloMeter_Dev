//
//  DdayViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

// 기념일 화면 뷰컨트롤러
class DdayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    let dDayView = DdayView()
    
    let dateFormat = DateFormatter()
    
    
    override func loadView() {
        view = dDayView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dDayView.dDayTableView.delegate = self
        dDayView.dDayTableView.dataSource = self
        if Model.shared.dataDdayTableView.isEmpty {
            setDataDdayList()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarCustom()
        Model.shared.focusCell()
        changeCell()
        setTopViewData()
        dDayView.dDayTableView.reloadData()
        print("뷰윌어페어에서 ??  ㅡㅡ>>>> \(Model.shared.dataDdayTableView.count)\n")
        print("기념일 추가 배열 있니 ㅡㅡㅡㅡ \(Model.shared.addDdayArray)")

    }
    func dismissModalViewController() {
        dismiss(animated: true) {
            // 모달 뷰 컨트롤러가 dismiss된 후에 호출할 메서드를 호출
            self.viewWillAppear(true)// 원하는 메서드 호출
          

            // 또는 다른 메서드 호출
            // self.myMethod()
        }
    }
    // 기념일 리스트 세팅
    func setDataDdayList() {
        Model.shared.startDay()
        Model.shared.calculateDays()
    }
    //기념일 리스트 tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.shared.dataDdayTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DdayTableViewCell", for: indexPath) as? DdayTableViewCell else { return UITableViewCell() }
        let target = Model.shared.dataDdayTableView[indexPath.row]
        cell.titleLabel.text = target.aniName
        cell.dateLabel.text = target.aniDate
        cell.remainingDaysLabel.text = target.countDdays
        cell.selectionStyle = .none //셀 선택 색상 없애기
        
        //이전 셀들의 라벨 텍스트 색상 변경
        if let anniversaryDate = dateFormat.date(from: target.aniDate) {
            let comparisonResult = Calendar.current.compare(anniversaryDate, to: Date(), toGranularity: .day)
            
            if comparisonResult == .orderedAscending { // 오늘 이전의 날짜
                cell.titleLabel.textColor = .gray3
                cell.dateLabel.textColor = .gray4
                cell.remainingDaysLabel.textColor = .gray3
            } else { // 오늘 이후의 날짜
                cell.titleLabel.textColor = .gray1
                cell.dateLabel.textColor = .gray2
                cell.remainingDaysLabel.textColor = .gray1
            }
        } else {
            // 기념일 날짜가 없는 경우 기본 색상 지정
            cell.titleLabel.textColor = .gray2
            cell.dateLabel.textColor = .gray2
            cell.remainingDaysLabel.textColor = .gray2
        }
        return cell
    }
    
    //첫번째 셀 변경
    func changeCell() {
        let indexPath = IndexPath(row: Model.shared.cellIndex, section: 0)
        dDayView.dDayTableView.scrollToRow(at: indexPath, at: .top, animated: true)
         
    }
    
    //상단 라벨 세팅
    func setTopViewData() {
        dateFormat.dateFormat = "yyyy.MM.dd"
        dDayView.startDateLabel.text = "첫 만남 \(dateFormat.string(from: Model.shared.startDate ?? Date()))"
        dDayView.countDateLabel.text = "\(abs(Model.shared.pmDday(from: Model.shared.startDate ?? Date()))+1)일째"
    }
    //기념일 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "기념일"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plusIcon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(plusButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        
    }
    
    //기념일 추가 버튼이벤트
    @objc func plusButtonTapped() {
        let vc = AddDdayViewController()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    //뒤로가기 버튼이벤트
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
}
