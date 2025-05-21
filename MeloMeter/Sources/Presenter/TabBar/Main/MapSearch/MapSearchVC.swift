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

//장소 검색 화면
class MapSearchVC: UIViewController, UIGestureRecognizerDelegate {
    
    private var disposeBag = DisposeBag()
    
    private var tapIdx = PublishSubject<Int>()
    
    init(viewModel: MapSearchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: MapSearchVM
    
    private let rescentLabel = UILabel().then {
        $0.text = "최근 검색"
        $0.font = FontManager.shared.semiBold(ofSize: 16)
    }
    
    let tableView = UITableView()
    
    let topSearchView = UIView().then {
        $0.layer.borderColor = UIColor.gray4.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
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
        view.backgroundColor = .white

        setBindings()
        setSearchView()
        setAutoLayout()

    }
    
    
    func setSearchView() {
        view.addSubview(topSearchView)
        
        topSearchView.addSubview(searchBar)
        topSearchView.addSubview(backIconView)
        
        topSearchView.snp.makeConstraints {
            $0.height.equalTo(50)
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
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setBindings() {
        
        tableView.register(MapSearchCell.self, forCellReuseIdentifier: "MapSearchCell")
        tableView.rx.itemSelected.map { $0.row }.bind(to: tapIdx).disposed(by: disposeBag)

        
        let input = MapSearchVM.Input(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear)).map({ _ in }).asObservable(), searchText: self.searchBar.rx.text.orEmpty.asObservable(), keyBoardBtnTapped:         searchBar.rx.searchButtonClicked.map{ [weak self] _ in
            guard let self else {return}; self.searchBar.resignFirstResponder() }.asObservable(), tapIdx: tapIdx, backBtnTapped: self.backIconView.rx.tapGesture().when(.recognized).asObservable())
        
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.resultModels
            .compactMap { $0 }
            .bind(to: tableView.rx.items(cellIdentifier: "MapSearchCell", cellType: MapSearchCell.self)) { row, model, cell in
                cell.configure(with: model.title)
            }
            .disposed(by: disposeBag)
        
        output.testingPickMarker.subscribe(onNext: { picked in
            
            
            
        }).disposed(by: disposeBag)
        
        
        
    }
    
    
    
}
