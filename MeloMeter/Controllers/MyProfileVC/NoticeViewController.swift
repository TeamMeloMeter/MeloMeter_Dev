//
//  NoticeViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit

class NoticeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    let noticeView = NoticeView()
    
    override func loadView() {
        view = noticeView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        noticeView.noticeTableView.delegate = self
        noticeView.noticeTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarCustom()
    }
    
    
    //셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    //적용할 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as? NoticeTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    // 셀 선택 이벤트 구현
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    //공지사항 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "공지사항"
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        
    }
    
    //뒤로가기 버튼이벤트
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
    
}
