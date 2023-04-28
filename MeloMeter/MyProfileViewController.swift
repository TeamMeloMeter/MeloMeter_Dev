//
//  MyProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

class MyProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myProfileTableView: UITableView!
    
    let tableViewLabel = MyProfileModel.tableViewLabel
    let tableViewImg = MyProfileModel.tableViewImg
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myProfileTableView.delegate = self
        myProfileTableView.dataSource = self
        
    }
    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewLabel.count
    }
    // 셀 안에 표시할 정보 삽입
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileTableViewCell", for: indexPath) as! MyProfileTableViewCell
        
        cell.iconImage.image = UIImage(named: tableViewImg[indexPath.row])
        cell.titleLabel.text = tableViewLabel[indexPath.row]
        cell.arrowLable.text = ">"
        return cell
    }
    
    // 총 셀 수를 가져와서 마지막 셀이라면 구분선 삭제
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        
        if indexPath.row == totalRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
}
