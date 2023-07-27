//
//  AnswerView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

class AnswerView: UIView {
    
    //질문내용 제목
    let qTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 인증이 뭔가요?"
        label.textColor = .black
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    //구분선
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    
    //스크롤뷰
    lazy var scrollView: UIScrollView = {
        let scView = UIScrollView()
        scView.backgroundColor = .white
        scView.indicatorStyle = .black
        scView.addSubview(answerContentView)

        return scView
    }()
    
    lazy var answerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(answerLabel)
        return view
    }()
    //답변내용
    let answerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "안녕하세요. 멜로미터입니다. \n\n회원 가입 시 입력하는 번호가 고객님의 멜로미터 아이디입니다. 아이디는 원활한 앱 사용을 위해~~ \n\n[계정 인증 방법]\n\n 가입 직후 발송된 멜로미터의 어쩌구 확인"
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
    }
    
    func addViews() {
        [qTitleLabel, lineView, scrollView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
       
        qTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        answerContentView.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qTitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            qTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 26),
            
            lineView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: qTitleLabel.bottomAnchor, constant: 23),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            answerContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            answerContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            answerContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            answerContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            answerContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            answerLabel.leadingAnchor.constraint(equalTo: answerContentView.leadingAnchor, constant: 16),
            answerLabel.topAnchor.constraint(equalTo: answerContentView.topAnchor, constant: 45),
            answerLabel.trailingAnchor.constraint(equalTo: answerContentView.trailingAnchor, constant: -52),
            answerLabel.bottomAnchor.constraint(equalTo: answerContentView.bottomAnchor, constant: -20),

        ])
        
    }
}
