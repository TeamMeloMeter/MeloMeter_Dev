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
    
    override func loadView() {
        view = dDayView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dDayView.dDayTableView.delegate = self
        dDayView.dDayTableView.dataSource = self
        navigationBarCustom()
    }
    
    //기념일 리스트 tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DdayTableViewCell", for: indexPath) as? DdayTableViewCell else { return UITableViewCell() }
        
        return cell
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
        
    }
    //뒤로가기 버튼이벤트
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
}
