//
//  MapSerchVC.swift
//  MeloMeter
//
//  Created by 양승완 on 5/16/25.
//

import UIKit
import NMapsMap
import RxCocoa
import RxSwift
import CoreLocation
import GoogleMobileAds

//메인 지도 화면
class MapSearchVC: UIViewController, UIGestureRecognizerDelegate {
    
    
    let tableView = UITableView()
    
    let topSearchView = UIView().then {
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
    }
    
    let searchBar = UISearchBar().then {
        $0.placeholder = "장소 주소 검색"
        $0.setImage(UIImage(), for: .search, state: .normal)
        $0.backgroundImage = UIImage()
        $0.searchTextField.backgroundColor = .clear
        
    }
    let backIconView =  UIImageView(image: UIImage(named: "backIcon")).then {
        $0.contentMode = .scaleAspectFit
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayout()
        setBindings()
        setSearchView()
    }
    
 
    
    func setTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setSearchView() {
 
        
        
        view.addSubview(topSearchView)
        
        topSearchView.addSubview(searchBar)
        topSearchView.addSubview(backIconView)
        
        topSearchView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(10)
        }
        backIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(4)
            $0.top.bottom.equalToSuperview()
        }
        
        
        
    }
    func setAutoLayout() {
        
    }

    func setBindings() {
        
        
    }



}
