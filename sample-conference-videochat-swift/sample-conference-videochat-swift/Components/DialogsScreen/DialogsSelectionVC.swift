//
//  DialogsSelectionVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/11/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

struct DialogsSelectionConstant {
    static let forwarded = "Message forwarded"
}

class DialogsSelectionVC: UITableViewController {
    
    //MARK: - Properties
    private let chatManager = ChatManager.instance
    private var dialogs: [QBChatDialog] = []
    private var selectedPaths = Set<IndexPath>()
    private var titleView = TitleView()
    var action: ChatActions?
    var message: QBChatMessage?
    internal var senderID: UInt = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        senderID = currentUser.ID
        
        navigationItem.titleView = titleView
        setupNavigationTitle()
        tableView.register(UINib(nibName: DialogCellConstant.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DialogCellConstant.reuseIdentifier)
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        if let action = action {
            if action == .Delete {
                let deleteButtonItem = UIBarButtonItem(title: "Delete",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(didTapDelete(_:)))
                navigationItem.rightBarButtonItem = deleteButtonItem
                deleteButtonItem.tintColor = .white
            } else if action == .Forward {
                let sendButtonItem = UIBarButtonItem(title: "Send",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(didTapSend(_:)))
                navigationItem.rightBarButtonItem = sendButtonItem
                sendButtonItem.tintColor = .white
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadContent()
        chatManager.delegate = self
    }
    
    //MARK: - Actions
    private func checkNavRightBarButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedPaths.isEmpty == true ? false : true
    }
    
    @objc func didTapSend(_ sender: UIBarButtonItem) {
        guard let originMessage = message else {
            return
        }
        
        let sendGroup = DispatchGroup()
        
        SVProgressHUD.show()
        
        for indexPath in self.selectedPaths {
            let dialog = self.dialogs[indexPath.row]
            guard let dialogID = dialog.id else {
                continue
            }
            sendGroup.enter()
            let forwardedMessage = QBChatMessage.markable()
            forwardedMessage.senderID = senderID
            forwardedMessage.deliveredIDs = [(NSNumber(value: senderID))]
            forwardedMessage.readIDs = [(NSNumber(value: senderID))]
            forwardedMessage.dateSent = Date()
            forwardedMessage.customParameters["save_to_history"] = true
            let originSenderUser = chatManager.storage.user(withID: originMessage.senderID)
            if let fullName = originSenderUser?.fullName {
                forwardedMessage.customParameters[ChatDataSourceConstant.forwardedMessage] = fullName
            } else {
                let currentUser = Profile()
                forwardedMessage.customParameters[ChatDataSourceConstant.forwardedMessage] = currentUser.fullName
            }
            forwardedMessage.dialogID = dialogID
            if let attachment = originMessage.attachments?.first {
                forwardedMessage.text = "[Attachment]"
                forwardedMessage.attachments = [attachment]
            } else {
                forwardedMessage.text = originMessage.text
            }
            chatManager.send(forwardedMessage, to: dialog) { (error) in
                sendGroup.leave()
                if let error = error {
                    debugPrint("[DialogsSelectionVC] sendMessage error: \(error.localizedDescription)")
                    return
                }
            }
        }
        sendGroup.notify(queue: DispatchQueue.main) {
            SVProgressHUD.dismiss()
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func didTapDelete(_ sender: UIBarButtonItem) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            SVProgressHUD.dismiss()
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return
        }
        
        if QBChat.instance.isConnected == true {
            let alertController = UIAlertController(title: "SA_STR_WARNING".localized,
                                                    message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOGS".localized,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
            
            let leaveAction = UIAlertAction(title: "SA_STR_DELETE".localized, style: .default) { (action:UIAlertAction) in
                SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized)
                
                let deleteGroup = DispatchGroup()
                
                for indexPath in self.selectedPaths {
                    let dialog = self.dialogs[indexPath.row]
                    
                    
                    guard let dialogID = dialog.id else {
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    if dialog.type == .private {
                        deleteGroup.enter()
                        self.chatManager.leaveDialog(withID: dialogID) { error in
                            if error == nil {
                                self.selectedPaths.remove(indexPath)
                            }
                            deleteGroup.leave()
                        }
                    } else if dialog.type == .publicGroup {
                        continue
                    } else {
                        // group
                        deleteGroup.enter()
                        let currentUser = Profile()
                        dialog.pullOccupantsIDs = [(NSNumber(value: currentUser.ID)).stringValue]
                        
                        let message = "\(currentUser.fullName) " + "SA_STR_USER_HAS_LEFT".localized
                        // Notifies occupants that user left the dialog.
                        self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                            if let error = error {
                                debugPrint("[DialogsViewController] sendLeaveMessage error: \(error.localizedDescription)")
                                SVProgressHUD.dismiss()
                                return
                            }
                            self.chatManager.leaveDialog(withID: dialogID) { error in
                                if error == nil {
                                    self.selectedPaths.remove(indexPath)
                                }
                                deleteGroup.leave()
                            }
                        })
                    }
                }
                deleteGroup.notify(queue: DispatchQueue.main) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(leaveAction)
            present(alertController, animated: true, completion: nil)
        } else {
            ChatManager.instance.connect {(error) in
                if error != nil {
                    SVProgressHUD.showSuccess(withStatus: "QBChat is not Connected")
                }
            }
        }
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
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
        
        cell.streamImageView.isHidden = true
        cell.joinButton.isHidden = true
        
        let chatDialog = dialogs[indexPath.row]
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        if action == ChatActions.Delete, chatDialog.type == .publicGroup {
            cell.contentView.backgroundColor = .clear
            cell.checkBoxView.backgroundColor = .clear
            cell.checkBoxView.isHidden = true
            cell.checkBoxImageView.isHidden = true
            cell.lastMessageDateLabel.isHidden = true
        } else {
            tableView.allowsMultipleSelection = true
            cell.checkBoxView.isHidden = false
            cell.unreadMessageCounterLabel.isHidden = true
            cell.unreadMessageCounterHolder.isHidden = true
            cell.lastMessageDateLabel.isHidden = true
            
            if self.selectedPaths.contains(indexPath) {
                cell.contentView.backgroundColor = UIColor(red:0.85, green:0.89, blue:0.97, alpha:1)
                cell.checkBoxImageView.isHidden = false
                cell.checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                              borderWidth: 0.0,
                                                              color: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1),
                                                              borderColor: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1))
            } else {
                cell.contentView.backgroundColor = .clear
                cell.checkBoxView.backgroundColor = .clear
                cell.checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                              borderWidth: 1.0,
                                                              borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
                cell.checkBoxImageView.isHidden = true
            }
        }
        
        cell.dialogLastMessage.text = chatDialog.lastMessageText
        if chatDialog.lastMessageText == nil && chatDialog.lastMessageID != nil {
            cell.dialogLastMessage.text = "[Attachment]"
        }
        
        cell.dialogName.text = cellModel.textLabelText
        cell.dialogAvatarLabel.backgroundColor = UInt(chatDialog.createdAt!.timeIntervalSince1970).generateColor()
        cell.dialogAvatarLabel.text = String(cellModel.textLabelText.stringByTrimingWhitespace().capitalized.first ?? Character("C"))
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dialog = dialogs[indexPath.row]
        if let action = action, action == .Delete,
            dialog.type == .publicGroup {
            let alertController = UIAlertController(title: "You cannot leave \(dialog.name ?? "Public chat")".localized,
                                                    message: nil,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        if selectedPaths.contains(indexPath) {
            selectedPaths.remove(indexPath)
        } else {
            selectedPaths.insert(indexPath)
        }
        checkNavRightBarButtonEnabled()
        setupNavigationTitle()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let dialog = dialogs[indexPath.row]
        if let action = action, action == .Delete,
            dialog.type == .publicGroup {
            return
        }
        if selectedPaths.contains(indexPath) {
            selectedPaths.remove(indexPath)
        } else {
            selectedPaths.insert(indexPath)
        }
        checkNavRightBarButtonEnabled()
        setupNavigationTitle()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if let action = action, action != .Delete || dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return
        }
        
        if QBChat.instance.isConnected == true {
            let dialog = dialogs[indexPath.row]
            if editingStyle != .delete || dialog.type == .publicGroup {
                return
            }
            
            let alertController = UIAlertController(title: "SA_STR_WARNING".localized,
                                                    message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
            
            let leaveAction = UIAlertAction(title: "SA_STR_DELETE".localized, style: .default) { (action:UIAlertAction) in
                SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized)
                
                guard let dialogID = dialog.id else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                if dialog.type == .private {
                    self.chatManager.leaveDialog(withID: dialogID) { error in
                        if error == nil {
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                } else {
                    
                    let currentUser = Profile()
                    // group
                    dialog.pullOccupantsIDs = [(NSNumber(value: currentUser.ID)).stringValue]
                    
                    let message = "\(currentUser.fullName) " + "SA_STR_USER_HAS_LEFT".localized
                    // Notifies occupants that user left the dialog.
                    self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                        if let error = error {
                            debugPrint("[DialogsViewController] sendLeaveMessage error: \(error.localizedDescription)")
                            SVProgressHUD.dismiss()
                            return
                        }
                        self.chatManager.leaveDialog(withID: dialogID) { error in
                            if error == nil {
                                self.dismiss(animated: false, completion: nil)
                            }
                        }
                    })
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(leaveAction)
            present(alertController, animated: true, completion: nil)
        } else {
            ChatManager.instance.connect { (error) in
                if error != nil {
                    SVProgressHUD.showSuccess(withStatus: "QBChat is not Connected")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialogID = sender as? String
            }
        }
    }
    
    // MARK: - Helpers
    private func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        setupNavigationTitle()
        tableView.reloadData()
    }
    
    private func setupNavigationTitle() {
        
        var title = DialogsConstant.forward
        if let action = action, action == .Delete {
            title = DialogsConstant.deleteChats
        }
        var chats = "chats"
        if selectedPaths.count == 1 {
            chats = "chat"
        }
        
        let numberChats = "\(selectedPaths.count) \(chats) selected"
        titleView.setupTitleView(title: title, subTitle: numberChats)
    }
}

// MARK: - ChatManagerDelegate
extension DialogsSelectionVC: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog, isOnCall: Bool?) {
        reloadContent()
        SVProgressHUD.dismiss()
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        reloadContent()
        SVProgressHUD.dismiss()
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
    }
}
