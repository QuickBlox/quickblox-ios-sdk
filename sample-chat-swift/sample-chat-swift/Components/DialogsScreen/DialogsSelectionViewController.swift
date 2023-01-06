//
//  DialogsSelectionVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/11/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

struct DialogsSelectionConstant {
    static let forwarded = "Message forwarded"
}

class DialogsSelectionViewController: DialogListViewController {
    
    //MARK: - Properties
    private var selectedPaths = Set<IndexPath>()
    private var titleView = TitleView()
    var action: ChatAction?
    var message: QBChatMessage?
    internal var senderID: UInt = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDialogs()
    }
    
    //MARK - Setup
    override func setupNavigationBar() {
        guard currentUser.isFull == true else {
            return
        }
        senderID = currentUser.ID
        navigationItem.titleView = titleView
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        if let action = action {
            if action == .delete {
                let deleteButtonItem = UIBarButtonItem(title: "Delete",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(didTapDelete(_:)))
                navigationItem.rightBarButtonItem = deleteButtonItem
                deleteButtonItem.tintColor = .white
            } else if action == .forward {
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
    
    override func setupNavigationTitle() {
        let title = action == .delete ? DialogsConstant.deleteChats : DialogsConstant.forward
        let chats = selectedPaths.count == 1 ? "chat" : "chats"
        let numberChats = "\(selectedPaths.count) \(chats) selected"
        titleView.setupTitleView(title: title, subTitle: numberChats)
    }
    
    override func setupDialogs() {
        reloadContent()
    }
    
    //MARK: - Actions
    private func checkNavRightBarButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedPaths.isEmpty == true ? false : true
    }
    
    @objc func didTapSend(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        guard let originMessage = message else {
            return
        }
        sender.isEnabled = false
        let sendGroup = DispatchGroup()
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
            forwardedMessage.customParameters[Key.saveToHistory] = true
            let originSenderUser = chatManager.storage.user(withID: originMessage.senderID)
            if let fullName = originSenderUser?.fullName {
                forwardedMessage.customParameters[Key.forwardedMessage] = fullName
            } else {
                let currentUser = Profile()
                forwardedMessage.customParameters[Key.forwardedMessage] = currentUser.fullName
            }
            forwardedMessage.dialogID = dialogID
            if let attachment = originMessage.attachments?.first {
                forwardedMessage.text = ChatManagerConstant.attachment
                forwardedMessage.attachments = [attachment]
            } else {
                forwardedMessage.text = originMessage.text
            }
            chatManager.send(forwardedMessage, to: dialog) { [weak self] (error) in
                sendGroup.leave()
                if let error = error {
                    debugPrint("[DialogsSelectionVC] sendMessage error: \(error.localizedDescription)")
                }
                self?.selectedPaths.remove(indexPath)
            }
        }
        sendGroup.notify(queue: DispatchQueue.main) {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func didTapDelete(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        let baseAlertMessage = "Do you really want to leave selected dialog"
        let alertMessage = self.selectedPaths.count == 1 ? baseAlertMessage + "?" : baseAlertMessage + "s?"
        let alertController = UIAlertController(title: "Warning",
                                                message: alertMessage,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let leaveAction = UIAlertAction(title: "Leave", style: .default) { (action:UIAlertAction) in
            sender.isEnabled = false
            let deleteGroup = DispatchGroup()
            for indexPath in self.selectedPaths {
                let dialog = self.dialogs[indexPath.row]
                self.progressView.start()
                guard let dialogID = dialog.id, dialog.type != .publicGroup else {
                    continue
                }
                deleteGroup.enter()
                self.chatManager.leaveDialog(withID: dialogID) { [weak self] error in
                    deleteGroup.leave()
                    if error == nil {
                        self?.selectedPaths.remove(indexPath)
                    }
                }
            }
            deleteGroup.notify(queue: DispatchQueue.main) {
                self.handleLeaveDialog()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - UITableViewDataSource
    override func configure(cell: DialogCell, for indexPath: IndexPath) {
        tableView.allowsMultipleSelection = true
        cell.checkBoxView.isHidden = false
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
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelectRowAtIndexPath(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleSelectRowAtIndexPath(indexPath)
    }
    
    private func handleSelectRowAtIndexPath(_ indexPath: IndexPath) {
        let dialog = dialogs[indexPath.row]
        if let action = action, action == .delete,
            dialog.type == .publicGroup {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "You cannot leave \(dialog.name ?? "Public chat")",
                                                        message: nil,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            if selectedPaths.contains(indexPath) {
                selectedPaths.remove(indexPath)
            } else {
                selectedPaths.insert(indexPath)
            }
            checkNavRightBarButtonEnabled()
            setupNavigationTitle()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if let action = action, action != .delete || dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    // MARK: - Helpers
    override func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        setupNavigationTitle()
        tableView.reloadData()
    }
    
    override func handleLeaveDialog() {
        super.handleLeaveDialog()
        self.navigationController?.popViewController(animated: false)
    }
}
