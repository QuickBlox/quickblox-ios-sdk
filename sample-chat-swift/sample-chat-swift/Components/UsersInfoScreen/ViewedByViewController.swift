//
//  ViewedByViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 31.01.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import UIKit

struct UsersInfoConstant {
    static let delivered = "Message delivered to"
    static let viewed = "Message viewed by"
    static let noUser = "No user with that name"
}

class ViewedByViewController: UserListViewController {
    //MARK: - Properties
    var dialogID: String!
    var dataSource: ChatDataSource!
    var messageID: String! {
        didSet {
            setupMessage()
        }
    }
    
    private var message: QBChatMessage? {
        didSet {
            setupUsers()
        }
    }
    private var titleView = TitleView()
    private let chatManager = ChatManager.instance
    
    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        
        refreshControl = nil
        navigationItem.titleView = titleView
        setupNavigationTitleByAction()
        QBChat.instance.addDelegate(self)
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        QBChat.instance.removeDelegate(self)
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Internal Methods
    private func setupMessage() {
        guard let ID = messageID else {
            return
        }
        chatManager.messages(withID: dialogID,
                             extendedRequest: ["_id": ID],
                             skip: 0,
                             limit: 1,
                             successCompletion: { [weak self] (messages, cancel) in
            guard let self = self, let message = messages.first else { return }
            self.message = message
        }, errorHandler: { (error) in
            debugPrint("[\(ViewedByViewController.className)] \(#function) Error: \(error?.localized ?? "Error")")
        })
    }
    
    private func setupNavigationTitleByAction() {
        let title = action == .viewedBy ? UsersInfoConstant.viewed : UsersInfoConstant.delivered
        let numberUsers = "\(self.userList.fetched.count) members"
        titleView.setupTitleView(title: title, subTitle: numberUsers)
    }
    
    private func setupUsers() {
        guard currentUser.isFull == true else {
            return
        }
        if let message = message, let action = action {
            if action == .viewedBy {
                //check and add users who read the message
                guard let readIDs = message.readIDs,
                      readIDs.isEmpty == false else {
                          return
                      }
                userList.fetched = chatManager.storage.users(withIDs: readIDs).filter({ $0.id != currentUser.ID })
            } else if action == .deliveredTo {
                //check and add users who delivered the message
                guard let deliveredIDs = message.deliveredIDs,
                      deliveredIDs.isEmpty == false else  {
                          return
                      }
                userList.fetched = chatManager.storage.users(withIDs: deliveredIDs).filter({ $0.id != currentUser.ID })
            }
        }
        setupNavigationTitleByAction()
        tableView.reloadData()
    }
    
    override func configure(_ cell: UserTableViewCell, for indexPath: IndexPath) {
        cell.checkBoxView.isHidden = true
        cell.checkBoxImageView.isHidden = true
        cell.isUserInteractionEnabled = false
    }
    
    //MARK: - QBChatDelegate
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if Profile().ID == readerID
            || action != ChatAction.viewedBy
            || messageID != message?.id {
            return
        }
        guard let dataSource = dataSource,let message = self.message else {
            return
        }
        if message.readIDs?.contains(NSNumber(value: readerID)) == false {
            message.readIDs?.append(NSNumber(value: readerID))
            dataSource.updateMessage(message)
        }
        self.message = message
        setupUsers()
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if Profile().ID == userID
            || action != ChatAction.deliveredTo
            || messageID != self.message?.id {
            return
        }
        guard let dataSource = dataSource,let message = self.message else {
            return
        }
        if message.deliveredIDs?.contains(NSNumber(value: userID)) == false {
            message.deliveredIDs?.append(NSNumber(value: userID))
            dataSource.updateMessage(message)
        }
        self.message = message
        setupUsers()
    }
    
    override func chatDidConnect() {
       setupMessage()
    }
    
    override func chatDidReconnect() {
        setupMessage()
    }
}
