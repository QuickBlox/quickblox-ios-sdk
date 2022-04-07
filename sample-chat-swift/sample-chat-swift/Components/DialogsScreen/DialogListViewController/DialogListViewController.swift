//
//  DialogListViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 08.01.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct DialogsConstant {
    static let dialogsPageLimit:Int = 100
    static let deleteChats = "Delete Chats"
    static let forward = "Forward to"
    static let chats = "Chats"
}

class DialogTableViewCellModel: NSObject {
    
    //MARK: - Properties
    var text: String = ""
    var unreadMessagesCounter: String?
    var isHiddenUnreadMessagesCounter = true
    var dialogIcon : UIImage?
    
    //MARK: - Life Cycle
    init(dialog: QBChatDialog) {
        super.init()
        
        text = dialog.name ?? "UN"
        // Unread messages counter label
        if dialog.unreadMessagesCount > 0 {
            var trimmedUnreadMessageCount = ""
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            unreadMessagesCounter = trimmedUnreadMessageCount
            isHiddenUnreadMessagesCounter = false
        } else {
            unreadMessagesCounter = nil
            isHiddenUnreadMessagesCounter = true
        }
        
        if dialog.type == .private {
            if dialog.recipientID == -1 {
                return
            }
            // Getting recipient from users.
            if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
               let fullName = recipient.fullName {
                self.text = fullName
            } else {
                ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
                    self?.text = user?.fullName ?? user?.login ?? ""
                }
            }
        }
    }
}

class DialogListViewController: UITableViewController {
    //MARK: - Properties
     let chatManager = ChatManager.instance
     var dialogs: [QBChatDialog] = []
     let currentUser = Profile()
    lazy var progressView: ProgressView = {
        let progressView = ProgressView.loadNib()
        return progressView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: DialogCellConstant.reuseIdentifier, bundle: nil),
                           forCellReuseIdentifier: DialogCellConstant.reuseIdentifier)
        setupNavigationBar()
        setupNavigationTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupDialogs()
        
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        progressView.stop()
    }
    
    //MARK: - Setup
    func setupNavigationBar() {
        // Can be overridden in a child class.
    }
    
    func setupNavigationTitle() {
        // Can be overridden in a child class.
    }
    
    func setupDialogs() {
        // Can be overridden in a child class.
    }
    
    func handleLeaveDialog() {
        // Can be overridden in a child class.
    }
    
    func configure(cell: DialogCell, for indexPath: IndexPath) {
        // Can be overridden in a child class.
    }
    
    // MARK: - Helpers
    func reloadContent() {
        refreshControl?.endRefreshing()
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DialogCellConstant.reuseIdentifier,
                                                       for: indexPath) as? DialogCell else {
            return UITableViewCell()
        }
        
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        cell.tag = indexPath.row
        
        let chatDialog = dialogs[indexPath.row]
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        cell.dialogName.text = cellModel.text
        cell.dialogAvatarLabel.backgroundColor = UInt(chatDialog.createdAt!.timeIntervalSince1970).generateColor()
        cell.dialogAvatarLabel.text = String(cellModel.text.stringByTrimingWhitespace().capitalized.first ?? Character("C"))
        cell.dialogLastMessage.text = chatDialog.lastMessageText
        if let dateSend = chatDialog.lastMessageDate {
            cell.lastMessageDateLabel.text = dateSend.setupDate()
        } else if let dateUpdate = chatDialog.updatedAt {
            cell.lastMessageDateLabel.text = dateUpdate.setupDate()
        }
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounter
        cell.unreadMessageCounterHolder.isHidden = cellModel.isHiddenUnreadMessagesCounter
        
        // Can be overridden in a child class.
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        let dialog = dialogs[indexPath.row]
        if editingStyle != .delete || dialog.type == .publicGroup {
            return
        }
        let leave = dialog.type == .private ? "delete" : "leave"
        let alertController = UIAlertController(title: "Warning",
                                                message: "Do you really want to \(leave) selected dialog?",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let leaveAction = UIAlertAction(title: leave.capitalized, style: .default) { (action:UIAlertAction) in
            guard let dialogID = dialog.id else {
                return
            }
            self.progressView.start()
            self.chatManager.leaveDialog(withID: dialogID) { [weak self] error in
                self?.progressView.stop()
                if let error = error {
                    self?.showAnimatedAlertView(nil, message: error)
                    return
                }
                self?.handleLeaveDialog()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Leave"
    }
}
