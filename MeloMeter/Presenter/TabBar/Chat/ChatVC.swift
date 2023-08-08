//
//  ChatVC.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
import RxCocoa
import RxSwift
import AnyFormatKit
import MessageKit

final class ChatVC: UIViewController {
    
    private let viewModel: ChatVM
    let disposeBag = DisposeBag()
    let messages: [MessageKit.MessageType] = []
    
    init(viewModel: ChatVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    // MARK: - Binding
    func setBindings() {
    }
    
    // MARK: - Event
    //오류 알럿

    //알럿 틀
//    func insertError() {
//        AlertManager(viewController: self)
//            .setTitle("통신실패")
//            .setMessage("서버와 통신에 실패했습니다\n 잠시후 다시\n 시도해주세요")
//            .addActionConfirm("확인")
//            .showCustomAlert()
//        hideProgressDialog()
//    }
    

    // MARK: - configure
    //뷰초기 셋팅
    func configure() {
        view.backgroundColor = .yellow
//        nameTF.delegate = self
//        birthTF.delegate = self
//        firstDayTF.delegate = self
//
//        [insertSubViwes, progressImage].forEach { view.addSubview($0) }
    }
    
    // MARK: - UI
    //서브 뷰 생성
    // lazy : 지연
    lazy var insertSubViwes: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()

    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {

    }
  
}

