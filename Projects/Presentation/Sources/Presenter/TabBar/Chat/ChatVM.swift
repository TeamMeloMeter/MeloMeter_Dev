//
//  ChatVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
import RxSwift
import RxCocoa
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

// MARK: - LoginViewModel
public class ChatVM {
    weak var coordinator: ChatCoordinator?
    private let disposeBag = DisposeBag()
    private var chatUseCase: ChatUseCase
    private var hundredQAUseCase: HundredQAUseCase
    private var answerArray: [AnswerModel] = []
    private var questionInfo: (String, String) = ("", "")
    private var nowChatList : [ChatModel] = []
    private var alreadySearchedId: [String] = []
    private var alreadySearchedModel: [ChatModel] = []
    private var searchingText: String?
    private var searchingIndex: Int = 0
    
    public struct Input {
        let viewDidLoadEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
        let searchBtnTapEvent: Observable<Void>
        let mySendTextMessage: Observable<ChatModel> // 이미지 전송 누르고 나서 데이터
        let mySendImageMessage: Observable<ChatModel>
        let reloadMessage: Observable<Int>
        
        // by seungwan
        let searchTextMessage: Observable<String>
        let keyboardSearchBtnTapped: Observable<Void>
        let exitBarButton: Observable<Void>
        let pickerLeftBtnTap: Observable<Void>
        let pickerRightBtnTap: Observable<Void>
    }
    
    public struct Output {
        var sendSuccess = PublishSubject<Bool>()
        var getMessage = PublishSubject<[ChatModel]>()
        var getMoreMessage = PublishSubject<[ChatModel]>()
        var getRealTimeMessage = PublishSubject<[ChatModel]>()
        
        // by seungwan
        var searchedIndex = PublishSubject<ChatModel>()
        var setChatingView = PublishSubject<Bool>()
        var notExistAlert = PublishSubject<Void>()
    }
    
    
    public struct DisplayInput {
        let viewWillApearEvent: Observable<Void>
        let lastAnswerBtnTapEvent: Observable<Void>
        let goAnswerBtnTapEvent: Observable<Void>
    }
    
    public struct DisplayOutput {
        var questionComplete = PublishSubject<String>()
        var questionText = PublishSubject<String>()
        var otherProfileImage = PublishSubject<UIImage>()
        var questionEmpty = PublishSubject<Bool>()
    }
    
    public init(coordinator: ChatCoordinator,
         chatUseCase: ChatUseCase,
         hundredQAUseCase: HundredQAUseCase) {
        self.coordinator = coordinator
        self.chatUseCase = chatUseCase
        self.hundredQAUseCase = hundredQAUseCase
    }
    
    public func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.chatUseCase.getChatMessageService()
                self.chatUseCase.startRealTimeChatMessage()
            })
            .disposed(by: disposeBag)
        
        input.reloadMessage
            .subscribe(onNext: { [weak self] num in
                guard let self = self else{ return }
                self.chatUseCase.getMoreChatMessageService(num: num)
                
            }).disposed(by: disposeBag)
        
        input.mySendTextMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                guard let message = myMessage.toChatMessage(),
                      let chatType = myMessage.toChatType() else {
                    output.sendSuccess.onNext(false)
                    return
                }
                self.chatUseCase.sendMessageService(chatMessage: message, chatType: chatType)
                    .subscribe(onSuccess: {
                        output.sendSuccess.onNext(true)
                    },onFailure: { _ in
                        output.sendSuccess.onNext(false)
                    }).disposed(by: disposeBag)
            }).disposed(by: disposeBag)
        
        
        input.mySendImageMessage
            .subscribe(onNext: {[weak self] myMessage in
                guard let self = self else{ return }
                guard let message = myMessage.toChatMessage(),
                      let chatType = myMessage.toChatType() else {
                    output.sendSuccess.onNext(false)
                    return
                }
                self.chatUseCase.sendMessageService(chatMessage: message, chatType: chatType)
                    .subscribe(onSuccess: {
                        output.sendSuccess.onNext(true)
                    },onFailure: { _ in
                        output.sendSuccess.onNext(false)
                    }).disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        self.chatUseCase.recieveChatMessageService
            .subscribe(onNext: { [weak self] chatMessageList in
                guard let self else {return}
                let models = (chatMessageList ?? []).map { $0.toChatModel() }
                output.getMessage.onNext(models)
                self.nowChatList = models
                
                
            })
            .disposed(by: disposeBag)
        
        
        self.chatUseCase.recieveMoreChatMessageService
            .subscribe(onNext: { chatMessageList in
                let models = (chatMessageList ?? []).map { $0.toChatModel() }
                output.getMoreMessage.onNext(models)
                self.nowChatList += models
                
            }).disposed(by: disposeBag)
        
        
        
        self.chatUseCase.recieveRealTimeMessageService
            .subscribe(onNext: { chatMessageList in
                let models = (chatMessageList ?? []).map { $0.toChatModel() }
                output.getRealTimeMessage.onNext(models)
            }).disposed(by: disposeBag)
        
        input.backBtnTapEvent
            .subscribe(onNext: {
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        
        
        //TODO: clean code (VC 코드 VM 에서 처리)
        Observable.zip(self.chatUseCase.recieveChatForSearch.asObservable(), self.chatUseCase.recieveMessageId.asObservable())
            .subscribe(onNext: { chatMessageList, messageId in
                
                
                let models = (chatMessageList ?? []).map { $0.toChatModel() }
                if !models.isEmpty {
                    output.getMoreMessage.onNext(models)
                    
                    let searchedModel = models.filter {
                        $0.messageId == messageId
                    }.first
                    
                    if let searchedModel = searchedModel {
                        
                        
                        output.searchedIndex.onNext(searchedModel)
                        self.alreadySearchedId.append(messageId)
                        self.alreadySearchedModel.append(searchedModel)
                        self.searchingIndex = self.alreadySearchedModel.count - 1
                    }
                    
                    self.nowChatList += models
                } else {
                    output.notExistAlert.onNext(())
                }
                
                
                
                
            }).disposed(by: disposeBag)
        
        input.searchBtnTapEvent.subscribe(onNext: { [weak self] in
            guard let self else {return}
            
            output.setChatingView.onNext(true)
            
        }).disposed(by: disposeBag)
        

        //MARK: right (아래 화살표) tap 시
        input.pickerRightBtnTap.subscribe(onNext: { [weak self] _ in
            guard let self, !alreadySearchedModel.isEmpty else {return}
            self.searchingIndex = searchingIndex > 0 ? searchingIndex - 1 : searchingIndex
            output.searchedIndex.onNext(alreadySearchedModel[searchingIndex])

        }).disposed(by: disposeBag)
        
        // MARK: 검색 시 by Seungwan
        Observable.merge(input.pickerLeftBtnTap.asObservable(), input.keyboardSearchBtnTapped.asObservable()).withLatestFrom(input.searchTextMessage).subscribe(onNext: { [weak self] searchText in
            guard let self else { return }
            
            if searchingIndex < alreadySearchedModel.count - 1 {
                searchingIndex = searchingIndex + 1
                output.searchedIndex.onNext(alreadySearchedModel[searchingIndex])
            } else {
                if searchText != self.searchingText {
                    self.alreadySearchedId = []
                    self.searchingText = searchText
                    searchingIndex = 0
                }
                
                var count = 0
                
                for i in stride(from: nowChatList.count - 1, to: -1, by: -1) {
                    let chat = nowChatList[i]
                    switch chat.kind {
                    case .text(let text):
                        if text.contains(searchText) && !self.alreadySearchedId.contains(chat.messageId) {
                            
                            output.searchedIndex.onNext(chat)
                            self.alreadySearchedModel.append(chat)
                            self.searchingIndex = alreadySearchedModel.count - 1
                            self.alreadySearchedId.append(chat.messageId)
                            break
                        }
                        count += 1
                        
                        if count == nowChatList.count {
                            self.chatUseCase.getMoreChatForSearch(num: self.nowChatList.count, searchText: searchText)
                        }
                        
                    default:
                        break
                    }
                }
            }
            
          
        }).disposed(by: disposeBag)
        
        
        input.exitBarButton.subscribe(onNext:{ [weak self] in
            guard let self else {return}
            output.setChatingView.onNext(false)
            
            
        }).disposed(by: disposeBag)
        
        return output
    }
    
    public func noticeTransform(input: DisplayInput, disposeBag: DisposeBag) -> DisplayOutput {
        let output = DisplayOutput()
        
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.chatUseCase.getProfileImage()
                    .subscribe(onSuccess: { data in
                        let image = data.flatMap { UIImage(data: $0) }
                            ?? UIImage(named: "defaultProfileImage")
                            ?? UIImage()
                        output.otherProfileImage.onNext(image)
                    })
                    .disposed(by: disposeBag)
                self.hundredQAUseCase.getAnswerList()
                    .subscribe(onSuccess: {[weak self] model in
                        guard let self = self else{ return }
                        let questionNumber = model.count - 1
                        let answerModel = model.dropLast(1)
                        var answers = answerModel.map{ $0.answerInfo }
                        let question = answerModel.map{ $0.questionText }
                        let beforeAnswers = answers.filter({ $0.count < 2 }).flatMap({$0})
                        if beforeAnswers.isEmpty {
                            self.questionInfo.1 = question[0]
                            self.questionInfo.0 = String(questionNumber)
                            if (answers.count == 1 && answers[0].count == 2) || (answers.count == 2 && answers[1].count == 2) {
                                output.questionComplete.onNext("오늘의 질문을 완료했어요!")
                                output.questionText.onNext(question[0])
                            }else {
                                output.questionComplete.onNext("백문백답 질문을 받아보세요!")
                                output.questionText.onNext("새로운 질문을 받아보세요!")
                            }
                            self.answerArray = answers.popLast() ?? []
                            
                        } else if beforeAnswers.count == 1 {
                            self.answerArray = answers[0]
                            self.questionInfo.1 = question[0]
                            self.questionInfo.0 = String(questionNumber)
                            output.questionComplete.onNext("\(String(questionNumber))번째 백문백답이 도착했어요!")
                            output.questionText.onNext(self.questionInfo.1)
                        } else {
                            self.answerArray = answers[1]
                            self.questionInfo.1 = question[1]
                            self.questionInfo.0 = String(questionNumber - 1)
                            output.questionComplete.onNext("\(String(questionNumber - 1))번째 백문백답이 도착했어요!")
                            output.questionText.onNext(self.questionInfo.1)
                        }
                        
                        
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.lastAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showHundredQAFlow()
            })
            .disposed(by: disposeBag)
        
        input.goAnswerBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                var myAnswerInfo = answerArray.filter{ $0.userId == .mine }.last ?? AnswerModel(userId: .mine, answerText: "", userName: "")
                var otherAnswerInfo = answerArray.filter{ $0.userId == .other }.last ?? AnswerModel(userId: .other, answerText: "", userName: "")
                let myName = UserDefaults.standard.string(forKey: "name") ?? ""
                let otherName = UserDefaults.standard.string(forKey: "otherUserName") ?? ""
                myAnswerInfo.userName = myName
                otherAnswerInfo.userName = otherName
                self.coordinator?.showReadAnswerVC(questionNumber: String(Int(self.questionInfo.0) ?? 2 - 1),
                                                   question: self.questionInfo.1,
                                                   myAnswerInfo: myAnswerInfo,
                                                   otherAnswerInfo: otherAnswerInfo)
            }).disposed(by: disposeBag)
        
        return output
    }
    
    public func datesCompare(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
}
