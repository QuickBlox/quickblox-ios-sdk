//
//  BaseDialogsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 08.01.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

struct DialogsConstant {
    static let dialogsPageLimit:Int = 100
    static let segueGoToChat = "goToChat"
    static let selectOpponents = "SelectOpponents"
    static let infoSegue = "PresentInfoViewController"
    static let deleteChats = "Delete Chats"
    static let forward = "Forward to"
    static let deleteDialogs = "deleteDialogs"
    static let chats = "Chats"
    static let call = "PresentCallViewController"
    static let onCall = "onCall"
}

class DialogTableViewCellModel: NSObject {
    
    //MARK: - Properties
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?
    
    //MARK: - Life Cycle
    init(dialog: QBChatDialog) {
        super.init()
        
        textLabelText = dialog.name ?? "UN"
        // Unread messages counter label
        if dialog.unreadMessagesCount > 0 {
            var trimmedUnreadMessageCount = ""
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            unreadMessagesCounterHiden = false
        } else {
            unreadMessagesCounterLabelText = nil
            unreadMessagesCounterHiden = true
        }
        
        if dialog.type == .private {
            if dialog.recipientID == -1 {
                return
            }
            // Getting recipient from users.
            if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
               let fullName = recipient.fullName {
                self.textLabelText = fullName
            } else {
                ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
                    self?.textLabelText = user?.fullName ?? user?.login ?? ""
                }
            }
        } else {
        }
    }
}

class BaseDialogsViewController: UITableViewController {
    //MARK: - Properties
     let chatManager = ChatManager.instance
     var dialogs: [QBChatDialog] = []
     let currentUser = Profile()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: DialogCellConstant.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DialogCellConstant.reuseIdentifier)
        setupNavigationBar()
        setupNavigationTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadContent()
        // configure it if necessary.
        setupDialogs()
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            } else {
                if QBChat.instance.isConnected == false, QBChat.instance.isConnecting == false {
                    self?.chatManager.connect()
                }
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
    }
    
    //MARK: - Setup
    func setupNavigationBar() {
        // configure it if necessary.
    }
    
    func setupNavigationTitle() {
        // configure it if necessary.
    }
    
    func setupDialogs() {
        // configure it if necessary.
    }
    
    func tableView(_ tableView: UITableView,
                                configureCell cell: DialogCell,
                                for indexPath: IndexPath) {
        // configure it if necessary.
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
        cell.dialogName.text = cellModel.textLabelText
        cell.dialogAvatarLabel.backgroundColor = UInt(chatDialog.createdAt!.timeIntervalSince1970).generateColor()
        cell.dialogAvatarLabel.text = String(cellModel.textLabelText.stringByTrimingWhitespace().capitalized.first ?? Character("C"))
        cell.dialogLastMessage.text = chatDialog.lastMessageText
        if chatDialog.lastMessageText == nil && chatDialog.lastMessageID != nil {
            cell.dialogLastMessage.text = "[Attachment]"
        }
        if let dateSend = chatDialog.lastMessageDate {
            cell.lastMessageDateLabel.text = setupDate(dateSend)
        } else if let dateUpdate = chatDialog.updatedAt {
            cell.lastMessageDateLabel.text = setupDate(dateUpdate)
        }
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden
        
        // configure it if necessary.
        self.tableView(tableView, configureCell: cell, for: indexPath)
        
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
            chatManager.connect()
            return
        }
        
        let dialog = dialogs[indexPath.row]
        if editingStyle != .delete || dialog.type == .publicGroup {
            return
        }
        let alertController = UIAlertController(title: "Warning",
                                                message: "Do you really want to leave selected dialog?",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .default) { (action:UIAlertAction) in
            
            SVProgressHUD.show(withStatus: "Leaving...")
            
            guard let dialogID = dialog.id else {
                SVProgressHUD.dismiss()
                return
            }
            
            if dialog.type == .private {
                self.chatManager.leaveDialog(withID: dialogID)
                SVProgressHUD.dismiss()
            } else {
                
                // group
                dialog.pullOccupantsIDs = [(NSNumber(value: self.currentUser.ID)).stringValue]
                
                let message = "\(self.currentUser.fullName) " + "has left"
                // Notifies occupants that user left the dialog.
                self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                    if let error = error {
                        debugPrint("[DialogsViewController] sendLeaveMessage error: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.chatManager.leaveDialog(withID: dialogID)
                    SVProgressHUD.dismiss()
                })
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
    
    // MARK: - Helpers
    func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        tableView.reloadData()
    }
    
    func setupDate(_ dateSent: Date) -> String {
        let formatter = DateFormatter()
        var dateString = ""
        
        if Calendar.current.isDateInToday(dateSent) == true {
            dateString = messageTimeDateFormatter.string(from: dateSent)
        } else if Calendar.current.isDateInYesterday(dateSent) == true {
            dateString = "Yesterday"
        } else if dateSent.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
            dateString = formatter.string(from: dateSent)
        } else {
            formatter.dateFormat = "d.MM.yy"
            var anotherYearDate = formatter.string(from: dateSent)
            if (anotherYearDate.hasPrefix("0")) {
                anotherYearDate.remove(at: anotherYearDate.startIndex)
            }
            dateString = anotherYearDate
        }
        
        return dateString
    }
}
